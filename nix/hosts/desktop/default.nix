# Desktop host configuration
{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/profiles/desktop.nix
    ../../modules/nixos/core/nix-network-settings.nix
  ];

  # Enable enhanced network timeout settings
  modules.my.nixNetworkSettings.enable = true;

  system.stateVersion = "23.11";

  # Desktop-specific: Enable NVIDIA GPU
  hardware.profiles.nvidia = {
    enable = true;
    driver = "stable";
    powerManagement = {
      enable = false; # Can cause issues with desktop GPUs
      finegrained = false; # Not needed for desktop
    };
  };

  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
    slack
    prusa-slicer
  ];

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
  };

  # Ollama with CUDA acceleration
  services.ollama = {
    enable = false;
    package = pkgs.ollama-cuda;
    openFirewall = true;
    host = "0.0.0.0"; # Listen on all interfaces for Tailnet access
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
        modules.my.qutebrowser.enable = true;
        modules.my.autorandr.enable = false;
        modules.my.bspwm.enable = true;
        modules.my.xmonad.enable = false;
        modules.my.hyprland.enable = true;
        modules.my.dunst.enable = false;
        modules.my.polybar.enable = false;
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
