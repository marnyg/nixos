{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.my.worktrunk;
in
{
  options.modules.my.worktrunk = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable worktrunk (`wt`) configuration.

        Manages `~/.config/worktrunk/config.toml` with a `post-remove`
        hook that kills the matching tmux session (matching the naming
        convention used by `tmux-worktree`: `basename worktree | tr . _`).

        Also installs fish shell integration so `wt switch` / `wt remove`
        can change the shell's directory (avoids the "Cannot change
        directory — shell integration not installed" warning and the
        stale-cwd errors when the worktree directory is removed underneath
        you).
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.worktrunk ];

    # User config for worktrunk.
    # Session names mirror those built in `tmux-worktree`/`tmux-sessionizer`:
    #   session_name = basename(path) | tr . _
    # which in worktrunk template syntax is `<name> | replace('.', '_')`.
    #
    # Two ordered pipeline blocks: switch the attached client to the primary
    # repo session first, then kill the removed worktree's session. Running
    # the kill first would leave tmux to pick *some* surviving session at
    # random for the orphaned client.
    xdg.configFile."worktrunk/config.toml".text = ''
      # Managed by home-manager (nix/modules/home/programs/worktrunk.nix)

      [[post-remove]]
      tmux-switch-back = "${pkgs.tmux}/bin/tmux switch-client -t $(${pkgs.coreutils}/bin/basename {{ primary_worktree_path }} | ${pkgs.coreutils}/bin/tr . _) 2>/dev/null || true"

      [[post-remove]]
      tmux-kill-session = "${pkgs.tmux}/bin/tmux kill-session -t {{ worktree_name | replace('.', '_') }} 2>/dev/null || true"
    '';

    # Fish shell integration — required for `wt switch` to cd, and to
    # avoid being stranded in a deleted worktree directory after `wt remove`.
    programs.fish.interactiveShellInit = mkIf config.programs.fish.enable ''
      ${pkgs.worktrunk}/bin/wt config shell init fish | source
    '';
  };
}
