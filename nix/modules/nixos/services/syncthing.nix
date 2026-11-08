# Syncthing on the desktop: one peer, the cluster (talos-config
# ADR-0046, k8s/apps/syncthing), reached through the mesh — the
# gateway's `syncthing` facet is tcp://syncthing.gw.mesh.internal:22000
# on this device's tun (modules.nixos.services.talos-mesh). No global
# discovery, no relays, no NAT: the cluster is addressed statically.
# Local announce stays on so another device on the LAN (the Mac) can
# be paired directly later; 22000 is open for that, the GUI is
# loopback-only.
#
# Folders are the sync set by temperature (ADR-0046): `notes` on every
# device, `docs` and `media` on the desktop + cluster. They live on
# the dedicated disk at /home/mar/sync (hosts/desktop/hardware.nix),
# not on the NVMe home.
#
# overrideDevices/overrideFolders: this file is the truth, the GUI is
# read-only for devices and folders. The cluster side is configured in
# ITS GUI (syncthing.gw.mesh.internal) — pairing is both sides naming
# each other's device ID. This desktop's ID: `syncthing --device-id`
# as mar (state in /home/mar/.config/syncthing).
{ lib, config, ... }:
with lib;
{
  options.modules.my.syncthing = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.my.syncthing.enable {
    services.syncthing = {
      enable = true;
      user = "mar";
      group = "users";
      dataDir = "/home/mar/sync";
      configDir = "/home/mar/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices.cluster = {
          id = "MH66KIH-ITKUVDR-YUBLROU-P7PCVQP-JSNJFLC-TJ72XPP-HILWDZO-XSVMRQC";
          addresses = [ "tcp://syncthing.gw.mesh.internal:22000" ];
        };
        folders = {
          notes = { path = "/home/mar/sync/notes"; devices = [ "cluster" ]; };
          docs = { path = "/home/mar/sync/docs"; devices = [ "cluster" ]; };
          media = { path = "/home/mar/sync/media"; devices = [ "cluster" ]; };
        };
        options = {
          globalAnnounceEnabled = false;
          relaysEnabled = false;
          natEnabled = false;
          localAnnounceEnabled = true;
          urAccepted = -1;
          crashReportingEnabled = false;
          listenAddresses = [ "tcp://0.0.0.0:22000" ];
        };
        gui.address = "127.0.0.1:8384";
      };
    };

    networking.firewall.allowedTCPPorts = [ 22000 ];
    networking.firewall.allowedUDPPorts = [ 21027 ];
  };
}
