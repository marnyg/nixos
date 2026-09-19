# talos-mesh: the Mesh v3 desktop presentation on macOS (talos-config
# 359.9.6, decision fgr). One launchd daemon, `irohup -tun`, started as
# root: it creates a utun, assigns 198.18.0.1, routes 198.18.0.0/15
# into it, then drops to the `_talosmesh` service user before anything
# touches the network. Names under mesh.internal that the mesh's name
# map knows resolve to fake IPs in that range; a TCP flow to
# <fake IP>:<facet port> becomes one iroh stream to that member
# (cp1.mesh.internal:50000 = apid, :6443 = kube-api).
#
# Static pieces this module declares, so the daemon needs no ongoing
# privilege:
#   - /etc/resolver/mesh.internal → 198.18.0.2, the resolver inside the
#     tun (same mechanism as Tailscale's ts.net; only CGO-linked
#     binaries honour it, which talosctl and kubectl are).
#   - the service user + group (nix-darwin users.knownUsers).
#   - KeepAlive while <state>/kit.json exists: not enrolled → launchd
#     leaves it alone instead of crash-looping; enrolled → it starts by
#     itself, and is restarted as root when it exits non-zero (the route
#     was flushed by a network transition and _talosmesh cannot re-add).
#
# First use enrolls the device — a wallet signature, which is a
# user-session act the daemon cannot perform. Once:
#   talos-mesh-enroll            # browser wallet; or `talos-mesh-enroll -paste`
# irohup runs as _talosmesh and serves the challenge page on a one-shot
# localhost URL; the wrapper opens that URL as you (the daemon user has
# no GUI session). launchd starts the daemon as soon as kit.json exists.
# -reenroll / -rekey pass through.
{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.darwin.services.talos-mesh;
  stateDir = "${cfg.stateRoot}/${cfg.name}.iroh";
  irohup = "${cfg.package}/bin/irohup";
  common = "-name ${escapeShellArg cfg.name} -hub ${escapeShellArg cfg.hub} -state ${escapeShellArg stateDir}";

  enroll = pkgs.writeShellScriptBin "talos-mesh-enroll" ''
    set -euo pipefail
    sudo mkdir -p ${escapeShellArg cfg.stateRoot}
    sudo chown -R ${cfg.user}:${cfg.user} ${escapeShellArg cfg.stateRoot}
    # irohup's output is relayed line by line; the one-shot challenge URL
    # it prints is opened here, in the invoking user's session. stdin
    # stays the terminal, so -paste works through the same pipeline.
    sudo -u ${cfg.user} HOME=/var/empty ${irohup} ${common} -enroll-only "$@" 2>&1 \
      | while IFS= read -r line; do
          printf '%s\n' "$line"
          case "$line" in
            *http://127.0.0.1:*) /usr/bin/open "$(printf '%s' "$line" | tr -d ' ')" || true ;;
          esac
        done
  '';
in
{
  options.modules.darwin.services.talos-mesh = {
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
      default = "_talosmesh";
      description = "Service user the daemon drops to after the utun is up.";
    };

    uid = mkOption {
      type = types.int;
      default = 560;
      description = "uid/gid of the service user (nix-darwin needs it explicit; must be unused).";
    };

    stateRoot = mkOption {
      type = types.str;
      default = "/var/lib/talos-mesh";
      description = "Owned by the service user; holds <name>.iroh/ (member key, certs) and the nebula files beside it.";
    };

    dnsUpstream = mkOption {
      type = types.str;
      default = "";
      example = "10.42.0.1";
      description = ''
        Where mesh.internal names NOT in the v3 name map are forwarded
        (nebula's DNS while the two planes coexist). Empty: NXDOMAIN.
      '';
    };
  };

  config = mkIf cfg.enable {
    users.knownUsers = [ cfg.user ];
    users.knownGroups = [ cfg.user ];
    users.groups.${cfg.user} = { gid = cfg.uid; description = "talos-mesh daemon"; };
    users.users.${cfg.user} = {
      uid = cfg.uid;
      gid = cfg.uid;
      home = "/var/empty";
      shell = "/usr/bin/false";
      description = "talos-mesh daemon";
      isHidden = true;
    };

    environment.etc."resolver/mesh.internal".text = ''
      # talos-mesh: irohup's split-DNS resolver inside the utun
      nameserver 198.18.0.2
    '';

    launchd.daemons.talos-mesh = {
      command = "${irohup} -tun ${common} -user ${cfg.user}"
        + optionalString (cfg.dnsUpstream != "") " -dns-upstream ${escapeShellArg cfg.dnsUpstream}";
      serviceConfig = {
        KeepAlive.PathState."${stateDir}/kit.json" = true;
        StandardOutPath = "/var/log/talos-mesh.log";
        StandardErrorPath = "/var/log/talos-mesh.log";
      };
    };

    environment.systemPackages = [ enroll ];
  };
}
