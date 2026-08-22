{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.my.quickshell = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.my.quickshell.enable {
    home.packages = [ pkgs.quickshell ];

    xdg.configFile."quickshell/shell.qml".source = ./shell.qml;

    # Tray applets (previously pulled in by the waybar module)
    services.blueman-applet.enable = true;
    services.network-manager-applet.enable = true;

    systemd.user.services.quickshell = {
      Unit = {
        Description = "Quickshell desktop shell";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        X-Restart-Triggers = [ "${config.xdg.configFile."quickshell/shell.qml".source}" ];
      };
      Service = {
        ExecStart = "${pkgs.quickshell}/bin/quickshell";
        Restart = "on-failure";
        RestartSec = 1;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
