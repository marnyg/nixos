# Netbird service module for NixOS
#
# Mirrors modules.darwin.services.netbird so a host declares extra meshes
# the same way on both platforms:
#
#   modules.<platform>.services.netbird.instances.<name> = {
#     managementUrl = "https://vpn.example.com";
#     wireguardPort = 51821;
#   };
#
# `enable` turns on the stock nixpkgs `services.netbird` (client `default`,
# interface wt0, port 51820). `instances.<name>` maps onto nixpkgs'
# `services.netbird.clients.<name>`, which already implements the isolation
# the darwin module has to hand-roll: per-client state dir, daemon socket,
# WireGuard interface/port, systemd unit and a `netbird-<name>` CLI wrapper.
# Several meshes can therefore be connected simultaneously
# (netbirdio/netbird#446).
#
# First use of an instance needs one interactive login:
#   netbird-<name> up        # opens SSO in the browser; token is persisted
#
# Platform differences worth knowing (see the darwin module for the other
# side):
#   - No DNS patch needed here. Upstream netbird pushes per-link resolver
#     config to systemd-resolved, so concurrent clients don't clobber each
#     other the way they do through macOS scutil (netbirdio/netbird#5504).
#     Two meshes serving the *same* domain (e.g. both defaulting to the
#     `netbird.selfhosted` peer zone) still resolve via only one of them.
#   - interfaceName is optional: nixpkgs defaults to `nb-<name>` (max 15
#     chars). On darwin it must be an explicit `utunN`.
#   - Clients are hardened by default (own user, socket restricted to the
#     `netbird-<name>` group), so CLI access needs group membership; see
#     `allowedUsers`.
{ lib, config, ... }:
with lib;
let
  cfg = config.modules.nixos.services.netbird;

  instanceModule = types.submodule {
    options = {
      managementUrl = mkOption {
        type = types.str;
        example = "https://vpn.example.com";
        description = "Management server URL for this instance.";
      };
      interfaceName = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "nb-work";
        description = ''
          WireGuard interface name. Null uses the nixpkgs default
          `nb-<name>`. Must differ from the default client's (wt0) and
          from every other instance.
        '';
      };
      wireguardPort = mkOption {
        type = types.port;
        example = 51821;
        description = ''
          WireGuard listen port. Must differ from the default client's
          (51820) and from every other instance.
        '';
      };
    };
  };
in
{
  options.modules.nixos.services.netbird = {
    enable = mkEnableOption "Netbird VPN daemon";

    instances = mkOption {
      type = types.attrsOf instanceModule;
      default = { };
      example = literalExpression ''
        {
          work = {
            managementUrl = "https://vpn.example.com";
            wireguardPort = 51821;
          };
        }
      '';
      description = ''
        Additional isolated netbird clients, run alongside the default one.
        Each is driven with the `netbird-<name>` wrapper.
      '';
    };

    allowedUsers = mkOption {
      type = types.listOf types.str;
      default = attrNames (filterAttrs (_: u: u.enable) (config.my.users or { }));
      defaultText = literalExpression "enabled users in my.users";
      description = ''
        Users added to each instance's `netbird-<name>` group so they can
        talk to the hardened daemon socket without root.
      '';
    };
  };

  config = mkMerge [
    (mkIf cfg.enable { services.netbird.enable = true; })

    (mkIf (cfg.instances != { }) {
      assertions =
        let
          ifaces = filter (i: i != null) (mapAttrsToList (_: i: i.interfaceName) cfg.instances);
          ports = mapAttrsToList (_: i: i.wireguardPort) cfg.instances;
        in
        [
          {
            assertion = !(elem "wt0" ifaces) && unique ifaces == ifaces;
            message = "modules.nixos.services.netbird.instances: interfaceName must be unique and not wt0 (used by the default client).";
          }
          {
            assertion = !(elem 51820 ports) && unique ports == ports;
            message = "modules.nixos.services.netbird.instances: wireguardPort must be unique and not 51820 (used by the default client).";
          }
        ];

      services.netbird.clients = mapAttrs
        (_: inst: {
          port = inst.wireguardPort;
          # NB_* env vars feed the daemon and the CLI wrapper alike, so the
          # first `netbird-<name> up` needs no --management-url.
          environment.NB_MANAGEMENT_URL = inst.managementUrl;
        } // optionalAttrs (inst.interfaceName != null) {
          interface = inst.interfaceName;
        })
        cfg.instances;

      users.users = genAttrs cfg.allowedUsers (_: {
        extraGroups = mapAttrsToList (name: _: "netbird-${name}") cfg.instances;
      });
    })
  ];
}
