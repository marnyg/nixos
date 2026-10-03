# talos-mesh: the Mesh v3 desktop presentation on NixOS — the linux
# twin of modules.darwin.services.talos-mesh (talos-config 359.9.6,
# decision fgr). One systemd service, `irohup -tun`, started as root:
# it creates the tun `talosmesh0`, assigns 198.18.0.1, routes
# 198.18.0.0/15 into it, declares the mesh.internal zone on that link in
# systemd-resolved (→ 198.18.0.2, the resolver inside the tun), then
# drops to the service user before anything touches the network. Names
# under mesh.internal that the mesh's name map knows resolve to fake
# IPs in that range; a TCP flow to <fake IP>:<facet port> becomes one
# iroh stream to that member (cp1.mesh.internal:50000 = apid, :6443 =
# kube-api, hub.mesh.internal:80 = the hub's admin facet).
#
# Differences from the darwin module, by platform:
#   - No static resolver file: irohup's privileged step pushes the zone
#     per-link through resolvectl, so it is gone with the interface.
#     Requires services.resolved (the desktop profile enables it).
#   - The unit is gated on <state>/kit.json (ConditionPathExists): not
#     enrolled → inactive, no crash loop; enrolled → starts at boot and
#     restarts as root on a non-zero exit (the route was flushed by a
#     network transition and the dropped daemon cannot re-add).
#   - Service user is a NixOS system user; no fixed uid needed.
#
# First use enrolls the device — a wallet signature, which is a
# user-session act the daemon cannot perform. Once:
#   talos-mesh-enroll            # browser wallet; or `talos-mesh-enroll -paste`
#   sudo systemctl start talos-mesh
# irohup runs as the service user and serves the challenge page on a
# one-shot localhost URL; the wrapper opens that URL as you (the daemon
# user has no GUI session). -reenroll / -rekey pass through.
{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.nixos.services.talos-mesh;
  stateDir = "${cfg.stateRoot}/${cfg.name}.iroh";
  irohup = "${cfg.package}/bin/irohup";
  common = "-name ${escapeShellArg cfg.name} -hub ${escapeShellArg cfg.hub} -state ${escapeShellArg stateDir}";

  enroll = pkgs.writeShellScriptBin "talos-mesh-enroll" ''
    set -euo pipefail
    sudo mkdir -p ${escapeShellArg stateDir}
    sudo chown -R ${cfg.user}:${cfg.user} ${escapeShellArg cfg.stateRoot}
    # irohup's output is relayed line by line; the one-shot challenge URL
    # it prints is opened here, in the invoking user's session. stdin
    # stays the terminal, so -paste works through the same pipeline.
    sudo -u ${cfg.user} HOME=${escapeShellArg cfg.stateRoot} ${irohup} ${common} -enroll-only "$@" 2>&1 \
      | while IFS= read -r line; do
          printf '%s\n' "$line"
          case "$line" in
            *http://127.0.0.1:*) ${pkgs.xdg-utils}/bin/xdg-open "$(printf '%s' "$line" | tr -d ' ')" >/dev/null 2>&1 || true ;;
          esac
        done
    echo "enrolled; start the daemon with: sudo systemctl start talos-mesh"
  '';
in
{
  options.modules.nixos.services.talos-mesh = {
    enable = mkEnableOption "Mesh v3 desktop presentation (irohup -tun)";

    package = mkOption {
      type = types.package;
      description = "talos-config's config-server-bin: provides bin/irohup.";
    };

    name = mkOption {
      type = types.str;
      default = config.networking.hostName;
      defaultText = literalExpression "config.networking.hostName";
      description = "Device name on the mesh (the approver may rename it).";
    };

    hub = mkOption {
      type = types.str;
      default = "https://marnyg-talos-config.fly.dev";
      description = "Hub base URL (enrollment, /.well-known, the iroh relay).";
    };

    user = mkOption {
      type = types.str;
      default = "talosmesh";
      description = "Service user the daemon drops to after the tun is up.";
    };

    stateRoot = mkOption {
      type = types.str;
      default = "/var/lib/talos-mesh";
      description = "Owned by the service user; holds <name>.iroh/ (member key, certs).";
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = config.services.resolved.enable;
      message = "modules.nixos.services.talos-mesh declares its split-DNS zone through systemd-resolved; enable services.resolved.";
    }];

    users.groups.${cfg.user} = { };
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.user;
      home = cfg.stateRoot;
      description = "talos-mesh daemon";
    };

    systemd.services.talos-mesh = {
      description = "talos-mesh: Mesh v3 desktop presentation (irohup -tun)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" "systemd-resolved.service" ];
      wants = [ "network-online.target" ];
      # Not enrolled → stays inactive instead of crash-looping; the
      # enroll wrapper tells you to start it once kit.json exists.
      unitConfig.ConditionPathExists = "${stateDir}/kit.json";
      # ip(8) for the tun/route, resolvectl for the zone.
      path = [ pkgs.iproute2 config.systemd.package ];
      serviceConfig = {
        ExecStart = "${irohup} -tun ${common} -user ${cfg.user}";
        # Starts as root by design (fgr): the tun, the route and the
        # resolved zone are its only privileged acts, then it setuids.
        User = "root";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    environment.systemPackages = [ enroll ];
  };
}
