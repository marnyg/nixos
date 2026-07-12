# wayvnc: VNC server for wlroots-based compositors (Hyprland here).
#
# Mirrors the running Wayland session over VNC so it can be reached from
# another tailnet device (e.g. macOS Screen Sharing: vnc://<host>:5900).
#
# It binds to `address` (0.0.0.0 by default), but reachability is gated by
# the firewall: the desktop host only opens `port` on the tailscale0
# interface, so in practice it is reachable only from the tailnet. There is
# no VNC-level auth — the tailnet is the trust boundary. If you later want
# defense-in-depth, add wayvnc auth (username/password + TLS) via a config
# file, ideally with the password sourced from agenix.
{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.my.wayvnc;
in {
  options.modules.my.wayvnc = {
    enable = mkEnableOption "wayvnc VNC server for the Hyprland session";

    address = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = ''
        Address wayvnc binds to. Left at 0.0.0.0 on purpose: the firewall
        only exposes the port on tailscale0, so binding to a hardcoded
        tailnet IP would add fragility (IP/ordering) without extra safety.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 5900;
      description = "TCP port wayvnc listens on.";
    };

    output = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "HDMI-A-2";
      description = ''
        Wayland output to capture. Null lets wayvnc pick the first output;
        set a name (see `hyprctl monitors`) to pin a specific monitor on a
        multi-head setup.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.wayvnc ];

    systemd.user.services.wayvnc = {
      Unit = {
        Description = "wayvnc VNC server for the Wayland session";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.wayvnc}/bin/wayvnc"
          + optionalString (cfg.output != null) " -o ${cfg.output}"
          + " ${cfg.address} ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
