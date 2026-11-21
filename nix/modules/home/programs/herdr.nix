{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.my.herdr;

  # Floating beads board: a lazygit-style fzf TUI over `bd` (issue list +
  # `bd show` preview, single-letter actions), opened in the focused
  # pane's repo. There is no beads TUI in nixpkgs (bv/lazybeads/perles),
  # hence a home-grown one. Keymap and logic live in herdr-beads.sh.
  beadsPopup = pkgs.writeShellApplication {
    name = "herdr-beads-popup";
    runtimeInputs = with pkgs; [ beads fzf jq less coreutils ];
    text = builtins.readFile ./herdr-beads.sh;
  };

  # Ovis mesh proxy (see options.modules.my.herdr.ovisMeshProxy).
  mp = cfg.ovisMeshProxy;
  ovisPort = 7317; # Ovis's default PORT
  # The file the Ovis server reads its settings from: KEY=value lines,
  # which is also what systemd's EnvironmentFile takes.
  ovisEnvFile = "${config.xdg.configHome}/herdr/plugins/config/devswha.ovis/env";
  # One site per mesh name, matched on Host. Any other Host (a local
  # name, a name rebound to 127.0.0.1) gets an empty answer, never the
  # token. `admin off`: Caddy's admin API would otherwise listen on
  # 127.0.0.1:2019, which an any-port mesh forward serves too.
  ovisCaddyfileText = pkgs.writeText "ovis-mesh-proxy.Caddyfile" ''
    {
    	admin off
    	persist_config off
    }
    ${concatMapStringsSep ", " (h: "http://${h}:${toString mp.port}") mp.hostNames} {
    	bind 127.0.0.1
    	reverse_proxy 127.0.0.1:${toString ovisPort} {
    		header_up Authorization "Bearer {env.OVIS_TOKEN}"
    		header_up -Tailscale-User-Login
    	}
    }
  '';
  ovisCaddyfile = pkgs.runCommand "ovis-mesh-proxy.Caddyfile" { nativeBuildInputs = [ pkgs.caddy ]; } ''
    HOME=$TMPDIR caddy validate --adapter caddyfile --config ${ovisCaddyfileText}
    cp ${ovisCaddyfileText} $out
  '';
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
        "AltanS/collie" # remote access to herdr sessions
        "persiyanov/herdr-reviewr" # code review plugin
        "andrewchng/herdr-sessionizer" # tmux-sessionizer-style fuzzy workspace picker
        # Browser split. Manifest requires herdr >= 0.8.2 (met: nixpkgs
        # ships 0.9.1). Exposes one action,
        # zenbu-labs.terminal-browser.open-split, not bound to a key yet.
        "zenbu-labs/terminal-browser/herdr-plugin"
        # Ovis: browser/phone client for herdr sessions (plugin id
        # devswha.ovis). Its startup hook brings up a web server on
        # 127.0.0.1:7317 whenever herdr starts. The plugin build needs
        # bun >= 1.4 and downloads upstream's signed prebuilt server, a
        # dynamically linked generic-linux ELF, so on NixOS it only runs
        # with programs.nix-ld (on via the desktop and wsl profiles).
        # Settings are KEY=value lines in `env` under
        # `herdr plugin config-dir devswha.ovis`; phone access
        # (`tailscale serve`) and device pairing stay imperative.
        # Access over the talos mesh without pairing: ovisMeshProxy.
        # A machine that ran upstream's install.sh has the plugin linked
        # locally instead, and herdr refuses to install over a link:
        # `herdr plugin unlink devswha.ovis` first.
        "devswha/ovis"
      ];
      description = ''
        GitHub `owner/repo[/subdir]` plugin sources. The subdir is part of
        the identity string `herdr plugin list` prints, so it must be
        included here or the presence check below never matches and the
        plugin is reinstalled on every activation. Each is installed with
        `herdr plugin install <src> --yes` on activation if not already
        present (checked against `herdr plugin list`). Removal is manual:
        `herdr plugin uninstall <id>`.
      '';
    };

    ovisMeshProxy = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Let the talos mesh be the sign-in for Ovis: a caller the mesh
          admitted opens `http://<hostName>:<port>` and is in, with no
          pairing code.

          Ovis cannot see who the mesh admitted (the device `tcp` facet
          is a raw splice to loopback), and the hook it offers a proxy
          that already signed its callers in is the shared token. So
          this (1) generates `OVIS_TOKEN` once per machine into the
          plugin's `env` file, mode 600, never in the nix store, and
          (2) runs Caddy as a user service on 127.0.0.1:<port> that adds
          `Authorization: Bearer <token>` to requests named for a mesh
          host name and passes them to Ovis.

          Consequences:
          - Reaching 127.0.0.1:<port> under a mesh name IS the
            credential, and Ovis is a shell as this user. Enable it only
            where that port is reachable by nothing but the mesh's
            any-port forward (`tcp=127.0.0.1:*`, admins only) and this
            machine itself.
          - With a token set, every other way in asks for it once per
            browser: this machine at 127.0.0.1:${toString ovisPort},
            `tailscale serve`. Devices already paired keep working.
            Read it with `grep OVIS_TOKEN` on the `env` file.
          - Ovis sees every mesh caller as the token: no per-device
            entry or Revoke. Revocation is the mesh's.
          - A running Ovis reads the token at start: after the first
            activation, `ovis stop && ovis start` (or restart herdr).
        '';
      };

      hostNames = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "nixos.mesh.internal" ];
        description = ''
          Names this machine is opened under through the mesh. Only
          requests whose Host is one of these get the token.
        '';
      };

      port = mkOption {
        type = types.port;
        default = 7318;
        description = "Loopback port the proxy listens on.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = mkIf mp.enable [
      {
        assertion = elem "devswha/ovis" cfg.plugins;
        message = "modules.my.herdr.ovisMeshProxy needs the devswha/ovis plugin in modules.my.herdr.plugins.";
      }
      {
        assertion = mp.hostNames != [ ];
        message = "modules.my.herdr.ovisMeshProxy.hostNames is empty: the proxy would serve nothing.";
      }
      {
        assertion = pkgs.stdenv.hostPlatform.isLinux;
        message = "modules.my.herdr.ovisMeshProxy is a systemd user service; no launchd agent is written yet.";
      }
    ];

    # The token is per machine and nobody has to know it but Ovis and the
    # proxy, so it is generated here instead of kept in agenix. Appended,
    # so settings already in the file stay.
    home.activation.ovisToken = mkIf mp.enable (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      _ovis_env=${escapeShellArg ovisEnvFile}
      if ! ${pkgs.gnugrep}/bin/grep -qs '^OVIS_TOKEN=.' "$_ovis_env"; then
        run mkdir -p "$(dirname "$_ovis_env")"
        run ${pkgs.bash}/bin/sh -c 'umask 077; t=$(${pkgs.openssl}/bin/openssl rand -hex 32) && [ -n "$t" ] && printf "OVIS_TOKEN=%s\n" "$t" >> "$1"' sh "$_ovis_env"
      fi
      run chmod 600 "$_ovis_env"
    '');

    systemd.user.services.ovis-mesh-proxy = mkIf mp.enable {
      Unit.Description = "Ovis mesh proxy: hands Ovis its token for callers the talos mesh admitted";
      Service = {
        # No leading `-`: without the token file the proxy must not run.
        EnvironmentFile = ovisEnvFile;
        ExecStart = "${pkgs.caddy}/bin/caddy run --adapter caddyfile --config ${ovisCaddyfile}";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "default.target" ];
    };

    programs.herdr = {
      enable = true;
      settings = {
        # Drop the blank row between panes (borders stay on).
        ui.pane_gaps = false;

        # Kitty graphics passthrough, required by terminal-browser to
        # draw pages into a pane. terminal-browser tries to write this
        # flag into config.toml itself, but the file is a read-only nix
        # store symlink, so it must be set here.
        experimental.kitty_graphics = true;

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
              # code review plugin. plugin_id is manifest-declared, not
              # derived from owner/repo (cf. AltanS/collie -> herdr.collie,
              # andrewchng/herdr-sessionizer -> sessionizer); verified
              # against installed plugin manifests and upstream
              # herdr-plugin.toml with herdr 0.9.1.
              # Also available: .toggle, .close
              key = "prefix+shift+v";
              type = "plugin_action";
              command = "persiyanov.reviewr.open";
              description = "open code review";
            }
            {
              # collie web bridge (remote access to herdr sessions).
              # collie actions are workspace-context only; other actions
              # (stop/restart/status/url) stay CLI-only for now.
              key = "prefix+shift+c";
              type = "plugin_action";
              command = "herdr.collie.start";
              description = "start collie web bridge";
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
              # beads board (fzf TUI) for the focused pane's repo.
              # prefix+b is herdr's default toggle_sidebar, hence shift.
              key = "prefix+shift+b";
              type = "popup";
              command = getExe beadsPopup;
              description = "beads board";
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

    # herdr spawns plugin actions with a minimal environment (no login
    # shell), so the Nix profile dir is NOT on their PATH and `bun` from
    # home.packages above is invisible to them. collie's collie-ctl.sh
    # resolve_bun() falls back to a fixed list of well-known locations --
    # ~/.bun/bin, ~/.local/bin, /usr/local/bin, /opt/homebrew/bin,
    # /usr/bin -- none of which is /etc/profiles/per-user/$USER/bin, so
    # its web bridge died with "bun not found on PATH" and never bound
    # $COLLIE_PORT. Planting bun in ~/.local/bin satisfies that fallback
    # (and any other plugin making the same assumption) without touching
    # BUN_INSTALL, which bun itself uses as its global-install prefix and
    # which must stay writable.
    home.file.".local/bin/bun".source = "${pkgs.bun}/bin/bun";

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
    # Activation runs with home-manager's bare PATH, so everything a
    # plugin's build step spawns has to be added here: bun for
    # sessionizer and ovis, tar + gzip for ovis, whose build unpacks the
    # release's client bundle with `tar -xzf` and otherwise fails with
    # `Executable not found in $PATH: "tar"`.
    home.activation.herdrPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${lib.makeBinPath [ pkgs.git pkgs.bun pkgs.gnutar pkgs.gzip ]}''${PATH:+:$PATH}"
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
