{ pkgs, lib, config, inputs, ... }:
with lib;
let
  cfg = config.modules.my.rex;
in
{
  # Upstream home-manager module from the Rex flake. It only declares
  # programs.rex / services.rex; nothing is installed until enabled below.
  imports = [ inputs.rex.homeManagerModules.default ];

  options.modules.my.rex = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable Rex (superlogical's multiplexer) via the upstream
        home-manager module: the `rex` command, its `xterm-rex` terminfo
        entry in `~/.terminfo`, the ssh guard, and (on Linux) a personal
        server as the systemd user service `rex`.

        The server only listens on its per-user unix socket. A
        home-manager switch never restarts it (that would end every
        session); run `systemctl --user restart rex` after an update.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.rex.enable = true;

    # Long-running personal server. Linux only: upstream asserts on macOS,
    # where the Rex app runs the server.
    services.rex.enable = pkgs.stdenv.hostPlatform.isLinux;

    # The ssh guard stops ssh from sending TERM=xterm-rex to hosts that
    # lack the entry. Upstream installs it through programs.ssh.includes,
    # which only takes effect when home-manager writes ~/.ssh/config, so
    # that is turned on here, without home-manager's default `Host *` block.
    programs.ssh.enable = mkDefault true;
    programs.ssh.enableDefaultConfig = mkDefault false;
  };
}
