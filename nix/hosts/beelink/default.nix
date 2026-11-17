# Beelink mini PC (Ryzen 7 255 / Radeon 780M) — a desktop-like host.
# Mirrors hosts/desktop minus the hardware-specific parts (NVIDIA, MT7922
# WiFi workarounds, scratch/nas1 mounts, PXE firewall ports) and minus
# Steam and Syncthing.
{ inputs, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/profiles/desktop.nix
    ../../modules/nixos/core/nix-network-settings.nix
  ];

  networking.hostName = "beelink";

  # Enable enhanced network timeout settings
  modules.my.nixNetworkSettings.enable = true;

  system.stateVersion = "26.11";

  environment.systemPackages = with pkgs; [
    slack
    prusa-slicer
  ];

  # Kernel modules needed for Docker/Dagger networking
  boot.kernelModules = [ "iptable_nat" "iptable_mangle" "iptable_filter" ];

  # Kernel sysctl parameters for Firefox memory mapping limits
  boot.kernel.sysctl = {
    "vm.max_map_count" = 1048576; # Increased from default 65530 for Firefox
    "vm.vfs_cache_pressure" = 300; # More aggressive cache reclaim
    "vm.page-cluster" = 0; # Disable readahead for swap
  };

  services.udev.extraRules = ''
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
    daemon.settings.features.buildkit = true;
  };

  # Remote desktop (wayvnc) reachable only over the tailnet. The service
  # binds 0.0.0.0, so this interface scoping is what keeps VNC off the LAN.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 5900 ];

  # Second NetBird client so the work mesh and the home mesh (default
  # client, wt0) are up simultaneously. Driven with
  # `netbird-swone up|down|status`; needs one interactive SSO login.
  modules.nixos.services.netbird.instances.swone = {
    managementUrl = "https://vpn.swonefinops.com";
    wireguardPort = 51821;
  };

  # Mesh v3 desktop presentation: tun + 198.18/15 + split DNS for
  # *.mesh.internal (the forge at git.gw.mesh.internal, the cache, cp1).
  # Enroll once: `talos-mesh-enroll`, then `sudo systemctl start talos-mesh`.
  modules.nixos.services.talos-mesh = {
    enable = true;
    package = inputs.talos-config.packages.${pkgs.stdenv.hostPlatform.system}.config-server-bin;
    # Serve the local sshd as the ssh facet (talos-config ADR-0038):
    # `ssh beelink.mesh.internal` from an admin device.
    forward.ssh = "127.0.0.1:22";
    # caCert: set once the daemon has minted this device's root — copy
    # /var/lib/talos-mesh/beelink.iroh/tls/ca.crt next to this file
    # (needed for https://*.gw.mesh.internal).
  };

  # Admin access from the desktop (mar@nixos), in addition to the keys in
  # users/mar/system.nix.
  users.users.mar.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQT5jLp3sX+tWW3OkxhOoKErVaDMfh/fuP+snI9L7Zz mar@desktop"
  ];

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
