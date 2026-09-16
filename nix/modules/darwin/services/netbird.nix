# Netbird service module for Darwin
#
# `enable` turns on the stock nix-darwin `services.netbird` daemon
# (`netbird`, socket /var/run/netbird/sock, state /var/lib/netbird).
#
# `instances.<name>` adds further, fully isolated daemons so the machine can
# be connected to several NetBird management servers *simultaneously*
# (netbirdio/netbird#446). Each instance gets its own state dir, daemon
# socket, WireGuard interface/port and log files, plus a `netbird-<name>`
# CLI wrapper that targets it. All netbird flags accept an `NB_<FLAG>` env
# var, so the wrapper is pure environment - no argument rewriting.
#
# First use of an instance needs one interactive login:
#   netbird-<name> up        # opens SSO in the browser; token is persisted
# After that `netbird-<name> up|down|status` works without SSO, and the
# daemon reconnects on boot.
#
# Caveat: `netbird profile` state lives in the per-user dir
# (~/Library/Application Support/netbird) and is shared by all daemons, so
# keep every daemon on its `default` profile - do not mix profiles with
# instances.
#
# macOS DNS: upstream (<= 0.78.2) writes every daemon's resolver config to
# the same scutil keys (State:/Network/Service/NetBird-Match-0/DNS ...), so
# with two daemons the last writer wins and the other mesh loses DNS.
# netbirdio/netbird#5504 scopes the keys by interface name; until it is
# released, `patchMultiInstanceDns` (default: on when instances are
# defined) applies that PR to the package used by *all* daemons. Drop the
# option and the vendored patch once nixpkgs ships a netbird containing it.
{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.darwin.services.netbird;

  # https://github.com/netbirdio/netbird/pull/5504
  # commit 1105d4a47faadb957e43e945837e1b7c879b0e4f, applies cleanly to v0.77.1
  multiInstanceDnsPatch = ./patches/netbird-pr5504-macos-dns-per-interface.patch;

  patchedNetbird = pkgs.netbird.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ multiInstanceDnsPatch ];
  });

  stateDir = name: "/var/lib/netbird-${name}";
  runDir = name: "/var/run/netbird-${name}";
  daemonAddr = name: "unix://${runDir name}/sock";

  instanceModule = types.submodule {
    options = {
      managementUrl = mkOption {
        type = types.str;
        example = "https://vpn.example.com";
        description = "Management server URL for this instance.";
      };
      interfaceName = mkOption {
        type = types.str;
        example = "utun101";
        description = ''
          WireGuard interface name. Must differ from the default daemon's
          (utun100) and from every other instance.
        '';
      };
      wireguardPort = mkOption {
        type = types.port;
        example = 51821;
        description = ''
          WireGuard listen port. Must differ from the default daemon's
          (51820) and from every other instance.
        '';
      };
    };
  };

  mkWrapper = name: inst:
    pkgs.writeShellScriptBin "netbird-${name}" ''
      export NB_DAEMON_ADDR="${daemonAddr name}"
      export NB_STATE_DIR="${stateDir name}/"
      export NB_MANAGEMENT_URL="${inst.managementUrl}"
      export NB_INTERFACE_NAME="${inst.interfaceName}"
      export NB_WIREGUARD_PORT="${toString inst.wireguardPort}"
      exec ${cfg.package}/bin/netbird "$@"
    '';

  mkDaemon = name: _inst:
    nameValuePair "netbird-${name}" {
      script = ''
        mkdir -p ${runDir name} ${stateDir name}
        exec ${cfg.package}/bin/netbird service run
      '';
      serviceConfig = {
        EnvironmentVariables = {
          NB_DAEMON_ADDR = daemonAddr name;
          NB_STATE_DIR = "${stateDir name}/";
          NB_CONFIG = "${stateDir name}/config.json";
          NB_LOG_FILE = "console";
        };
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/var/log/netbird-${name}.out.log";
        StandardErrorPath = "/var/log/netbird-${name}.err.log";
      };
    };
in
{
  options.modules.darwin.services.netbird = {
    enable = mkEnableOption "Netbird VPN daemon";

    package = mkOption {
      type = types.package;
      default = config.services.netbird.package;
      defaultText = literalExpression "config.services.netbird.package";
      description = "netbird package used by the additional instances.";
    };

    patchMultiInstanceDns = mkOption {
      type = types.bool;
      default = cfg.instances != { };
      defaultText = literalExpression "config.modules.darwin.services.netbird.instances != { }";
      description = ''
        Build netbird with netbirdio/netbird#5504 so concurrent daemons do
        not overwrite each other's macOS DNS configuration. Applies to the
        default daemon and all instances (they share one package).
      '';
    };

    instances = mkOption {
      type = types.attrsOf instanceModule;
      default = { };
      example = literalExpression ''
        {
          work = {
            managementUrl = "https://vpn.example.com";
            interfaceName = "utun101";
            wireguardPort = 51821;
          };
        }
      '';
      description = ''
        Additional isolated netbird daemons, run alongside the default one.
        Each is driven with the `netbird-<name>` wrapper.
      '';
    };
  };

  config = mkMerge [
    (mkIf cfg.enable { services.netbird.enable = true; })

    (mkIf cfg.patchMultiInstanceDns {
      services.netbird.package = mkDefault patchedNetbird;
    })

    (mkIf (cfg.instances != { }) {
      assertions =
        let
          ifaces = mapAttrsToList (_: i: i.interfaceName) cfg.instances;
          ports = mapAttrsToList (_: i: i.wireguardPort) cfg.instances;
        in
        [
          {
            assertion = !(elem "utun100" ifaces) && unique ifaces == ifaces;
            message = "modules.darwin.services.netbird.instances: interfaceName must be unique and not utun100 (used by the default daemon).";
          }
          {
            assertion = !(elem 51820 ports) && unique ports == ports;
            message = "modules.darwin.services.netbird.instances: wireguardPort must be unique and not 51820 (used by the default daemon).";
          }
        ];

      launchd.daemons = mapAttrs' mkDaemon cfg.instances;

      environment.systemPackages = mapAttrsToList mkWrapper cfg.instances;
    })
  ];
}
