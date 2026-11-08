# Desktop host configuration
{ inputs, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/profiles/desktop.nix
    ../../modules/nixos/core/nix-network-settings.nix
  ];

  # Enable enhanced network timeout settings
  modules.my.nixNetworkSettings.enable = true;

  # Syncthing against the cluster peer over the mesh (ADR-0046); the
  # folders live on the dedicated disk at /home/mar/sync (hardware.nix).
  modules.my.syncthing.enable = true;

  system.stateVersion = "23.11";

  # Desktop-specific: Enable NVIDIA GPU
  hardware.profiles.nvidia = {
    enable = true;
    driver = "stable";
    powerManagement = {
      # Installs nvidia-suspend/resume units + NVreg_PreserveVideoMemoryAllocations=1
      # so VRAM survives suspend. Without it the GPU context is lost on resume:
      # Xid 13 graphics exception -> Hyprland SIGABRT in GL begin (crash 2026-07-18,
      # hyprlandCrashReport37296.txt).
      enable = true;
      finegrained = false; # Laptop-only (RTD3); not applicable to desktop
    };
  };

  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
    slack
    prusa-slicer
    cifs-utils # mount.cifs for the nas1 share below
  ];

  # nas1's `transfer` SMB share (talos-config k8s/apps/files: the samba
  # pod with hostPort 445 on nas1, user `mar`). Mounted alongside the
  # local disks; an automount so a down nas1 never blocks boot — the
  # mount happens on first access and drops after 10 min idle.
  # Credentials live outside the store and the repo:
  #   /etc/nixos/smb-transfer.cred  (root:root 0600)
  #     username=mar
  #     password=<ACCOUNT_mar from the files/samba-users secret>
  fileSystems."/home/mar/disks/nas1-transfer" = {
    device = "//10.0.0.74/transfer";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/smb-transfer.cred"
      "vers=3.1.1"
      "uid=1000"
      "gid=100"
      "file_mode=0664"
      "dir_mode=0775"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=10s"
      "_netdev"
      "nofail"
    ];
  };

  # Disable PCIe ASPM on MT7921E WiFi to prevent chip-reset loops and kernel
  # oopses (mt7921e is the only parameter the driver actually accepts; the
  # previous `power_save=0` was silently ignored — see kernel log
  # "mt7921e: unknown parameter 'power_save' ignored").
  boot.extraModprobeConfig = ''
    options mt7921e disable_aspm=1
  '';

  # The module-level `disable_aspm=1` above was not enough: the MT7922 still
  # wedged ~16h into uptime with "driver own failed" / "chip reset failed",
  # leaving wlp12s0 stuck in NM state `unavailable`. Two extra mitigations:
  #
  # 1. Force ASPM off globally at the PCIe level. The per-module knob only
  #    covers the radio's own link state; `pcie_aspm=off` keeps the whole
  #    bus out of the low-power states that trigger the firmware wedge.
  boot.kernelParams = [ "pcie_aspm=off" ];

  # 2. Pin runtime power management "on" for the WiFi device so the kernel
  #    never autosuspends it into the bad state. Matched by PCI vendor/device
  #    (14c3:0616 = MediaTek MT7922) rather than bus address, which can shift.
  #    The udev rule itself lives in the consolidated `services.udev.extraRules`
  #    block below (NixOS only allows the attribute to be defined once).

  # Kernel modules needed for Docker/Dagger networking
  boot.kernelModules = [ "iptable_nat" "iptable_mangle" "iptable_filter" "amdgpu" ];

  # Kernel sysctl parameters for Firefox memory mapping limits
  boot.kernel.sysctl = {
    "vm.max_map_count" = 1048576; # Increased from default 65530 for Firefox
    "vm.vfs_cache_pressure" = 300; # More aggressive cache reclaim
    "vm.page-cluster" = 0; # Disable readahead for swap
  };

  # Auto-upgrade configuration specific to this host
  system.autoUpgrade = {
    enable = false;
    flake = "github:marnyg/nixos#desktop";
  };

  # Gaming support (desktop-specific)
  programs.steam.enable = true;

  services.udev.extraRules = ''
    # Keep the MT7922 WiFi (14c3:0616) out of PCI runtime suspend; see the
    # mt7921e chip-reset mitigations near the top of this file.
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x14c3", ATTR{device}=="0x0616", ATTR{power/control}="on"

    # ZSA keyboard DFU flashing
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="0791", MODE:="0666"
  '';

  # Delegate cgroup controllers for rootless containers (k3s, podman)
  systemd.services."user@".serviceConfig.Delegate = "cpuset cpu io memory pids";

  # Docker configuration for Dagger support
  virtualisation.docker = {
    enable = true;
    extraOptions = "--iptables=true";
    daemon.settings = {
      features = {
        buildkit = true;
      };
    };
  };

  # PXE boot server firewall rules
  networking.firewall = {
    allowedUDPPorts = [ 67 69 ]; # DHCP and TFTP
    allowedTCPPorts = [ 50084 8080 ]; # HTTP booter, config server

    # Remote desktop (wayvnc) reachable only over the tailnet. The service
    # binds 0.0.0.0, so this interface scoping is what keeps VNC off the LAN.
    interfaces.tailscale0.allowedTCPPorts = [ 5900 ];
  };

  # Ollama with CUDA acceleration
  services.ollama = {
    enable = false;
    package = pkgs.ollama-cuda;
    openFirewall = true;
    host = "0.0.0.0"; # Listen on all interfaces for Tailnet access
  };

  # Second NetBird client so the work mesh and the home mesh (default
  # client, wt0) are up simultaneously. Driven with
  # `netbird-swone up|down|status`; needs one interactive SSO login.
  modules.nixos.services.netbird.instances.swone = {
    managementUrl = "https://vpn.swonefinops.com";
    wireguardPort = 51821;
  };

  # Mesh v3 desktop presentation: tun + 198.18/15 + split DNS for
  # *.mesh.internal, so talosctl/kubectl/`nix run .#apply` reach cp1
  # and the hub by name over iroh. Enroll once: `talos-mesh-enroll`.
  modules.nixos.services.talos-mesh = {
    enable = true;
    package = inputs.talos-config.packages.${pkgs.stdenv.hostPlatform.system}.config-server-bin;
    # Serve the local sshd as the ssh facet (talos-config ADR-0038):
    # `ssh nixos.mesh.internal` from an admin device.
    forward.ssh = "127.0.0.1:22";
    # The daemon's device root (ADR-0033), copied out of
    # /var/lib/talos-mesh/nixos.iroh/tls/ca.crt: https://*.gw.mesh.internal.
    caCert = ./talos-mesh-ca.crt;
  };

  # User configuration
  my.users.mar = {
    enable = true;
    enableHome = true;
    profiles = [ "developer" "desktop" ];

    extraHomeModules = [
      {
        # Module overrides specific to this host
        modules.my.sharedDefaults.enable = true;
        modules.my.nixvim.enable = true;
        modules.my.git.enable = true;
        modules.my.fish.enable = true;
        modules.my.direnv.enable = true;
        modules.my.zellij.enable = false;
        modules.my.tmux.enable = true;
        modules.my.firefox.enable = true;
        # Firefox keeps its own NSS store; trust the mesh device root there.
        programs.firefox.policies.Certificates.Install = [ "${./talos-mesh-ca.crt}" ];
        modules.my.qutebrowser.enable = true;
        modules.my.autorandr.enable = false;
        modules.my.bspwm.enable = false;
        modules.my.xmonad.enable = false;
        modules.my.hyprland.enable = true;
        modules.my.wayvnc.enable = true;
        modules.my.dunst.enable = false;
        modules.my.waybar.enable = false;
        modules.my.quickshell.enable = true;
        modules.my.kitty.enable = false;
        modules.my.ghostty.enable = true;
        modules.my.newsboat.enable = false;
        modules.my.spotifyd.enable = false;
        modules.my.other.enable = false;
        modules.my.myPackages.enable = true;
        modules.my.cloneDefaultRepos.enable = true;

        programs.yazi.enable = true;
      }
    ];
  };
}
