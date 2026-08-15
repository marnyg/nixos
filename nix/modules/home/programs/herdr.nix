{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.my.herdr;
in
{
  options.modules.my.herdr = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable herdr (agent multiplexer) with declarative config and
        semi-declarative plugin management.

        Config (`~/.config/herdr/config.toml`) is fully managed by the
        upstream `programs.herdr` home-manager module. Plugins are
        inherently stateful (git checkout + plugins.json registry +
        per-plugin build steps), so they are installed idempotently via
        an activation hook instead of being pinned in the nix store.
      '';
    };

    plugins = mkOption {
      type = types.listOf types.str;
      default = [
        "dcolinmorgan/herdr-remote" # menu bar / phone / Telegram agent dashboard
        "andrewchng/herdr-sessionizer" # tmux-sessionizer-style fuzzy workspace picker
      ];
      description = ''
        GitHub `owner/repo` plugin sources. Each is installed with
        `herdr plugin install <src> --yes` on activation if not already
        present (checked against `herdr plugin list`). Removal is manual:
        `herdr plugin uninstall <id>`.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.herdr = {
      enable = true;
      settings = {
        # Keybindings ported from the tmux setup (tmux.nix) so herdr
        # matches tmux muscle memory. herdr resolves conflicts in favor
        # of user bindings (defaults on taken keys are silently disabled),
        # so displaced built-ins are explicitly relocated below.
        #
        # tmux equivalents already matching herdr defaults (untouched):
        #   prefix     = ctrl+b     | copy mode = prefix+[
        #   new tab    = prefix+c   | tab 1-9   = prefix+1..9
        #   tab picker = prefix+w (~ tmux choose-tree)
        #
        # Not ported:
        #   - direct ctrl+h/j/k/l pane nav (vim-tmux-navigator): herdr
        #     would steal these globally from nvim/shell; pane focus
        #     stays on herdr defaults prefix+h/j/k/l.
        #   - prefix+k keybinding-list popup: clashes with pane-up;
        #     herdr has built-in help on prefix+?.
        #   - M-u attach-to-cwd, ctrl+arrows resize (use resize mode).
        keys = {
          # tmux: prefix+d detach (herdr default: prefix+q)
          detach = "prefix+d";
          # tmux: prefix+C-h / C-l = prev/next window
          previous_tab = "prefix+ctrl+h";
          next_tab = "prefix+ctrl+l";
          # tmux: prefix+C-j / C-k = prev/next session
          previous_workspace = "prefix+ctrl+j";
          next_workspace = "prefix+ctrl+k";
          # tmux: prefix+, rename window / prefix+$ rename session
          rename_tab = "prefix+comma";
          rename_workspace = "prefix+$";
          # tmux: prefix+\" stacked split, prefix+% side-by-side split
          split_horizontal = "prefix+double_quote";
          split_vertical = "prefix+percent";
          # tmux: prefix+x kills the *session* (with confirm) in tmux.nix
          close_workspace = "prefix+x";
          close_pane = "prefix+shift+x"; # displaced by close_workspace
          close_tab = "prefix+ampersand"; # tmux default: & kill window
          # tmux: prefix+r reloads config
          reload_config = "prefix+r";
          resize_mode = "prefix+shift+r"; # displaced; covers tmux C-arrows
          # session navigator, displaced by the gitui popup on prefix+g
          goto = "prefix+shift+g";

          # Popups mirror the tmux display-popup bindings (commands
          # resolved from PATH, same as the tmux binds).
          command = [
            {
              # tmux: prefix+f sessionizer
              key = "prefix+f";
              type = "plugin_action";
              command = "sessionizer.open";
              description = "open project workspace";
            }
            {
              # tmux: prefix+W new worktree (create or reopen)
              key = "prefix+shift+w";
              type = "plugin_action";
              command = "sessionizer.worktree-open";
              description = "open worktree workspace";
            }
            {
              # tmux: prefix+g gitui popup
              key = "prefix+g";
              type = "popup";
              command = "gitui";
              description = "gitui";
              width = "90%";
              height = "90%";
            }
            {
              # tmux: prefix+y yazi popup
              key = "prefix+y";
              type = "popup";
              command = "yazi";
              description = "yazi file manager";
              width = "90%";
              height = "90%";
            }
            {
              # tmux: prefix+m spotify popup (plain popup; tmux's
              # detach-toggle via dedicated session has no herdr analog)
              key = "prefix+m";
              type = "popup";
              command = "spotify_player";
              description = "spotify player";
              width = "90%";
              height = "90%";
            }
            {
              # tmux: prefix+n notes (side pane in tmux, popup here;
              # freed because next_tab moved to prefix+ctrl+l)
              key = "prefix+n";
              type = "popup";
              command = "cd ~/git/notes && nvim index.norg";
              description = "notes";
              width = "90%";
              height = "90%";
            }
          ];
        };
      };
    };

    # Runtime deps for herdr-sessionizer (bun build+runtime, fzf pickers).
    # bat (richer README previews) is already enabled via programs.bat.
    home.packages = with pkgs; [ bun fzf ];

    # Sessionizer plugin config — mirrors the tmux-sessionizer script in
    # tmux.nix:
    #   - same project roots (globs supported by the plugin)
    #   - depth 4, git repos only
    #   - no [tabs]/[layout] => new workspaces open a plain shell,
    #     exactly like `tmux new-session` in the script
    #   - popup picker at 90%x90%, like `tmux display-popup -w 90% -h 90%`
    # Known gap vs tmux: the script also picks up non-git `.envrc` dirs;
    # the plugin only supports git_only true/false (false = every child
    # dir, far too noisy at depth 4), so .envrc-only projects are omitted.
    # Per-repo layout overrides remain available via `.sessionizer/config.toml`
    # checked into a repo.
    xdg.configFile."herdr/plugins/config/sessionizer/config.toml".text = ''
      # Managed by home-manager (nix/modules/home/programs/herdr.nix)

      [projects]
      roots = [
        "~/git",
        "~/disks/*/git*",
        "~/disks/*/archive",
        "~/disks/*/etc/nixos",
      ]
      git_only = true
      depth = 4

      [ui]
      placement = "popup" # needs herdr >= 0.7.4
      width = "90%"
      height = "90%"
    '';

    # Idempotent plugin install. Network failures are non-fatal — the
    # install is retried on the next activation.
    home.activation.herdrPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${lib.makeBinPath [ pkgs.git pkgs.bun ]}''${PATH:+:$PATH}"
      _herdr=${lib.getExe pkgs.herdr}
      _installed="$("$_herdr" plugin list 2>/dev/null || true)"
      for _src in ${escapeShellArgs cfg.plugins}; do
        if ! printf '%s' "$_installed" | ${pkgs.gnugrep}/bin/grep -qF "github:$_src@"; then
          run "$_herdr" plugin install "$_src" --yes \
            || echo "warning: herdr plugin install $_src failed (offline?); retried on next activation"
        fi
      done
    '';
  };
}
