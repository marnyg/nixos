# Laptop system profile
{ lib, ... }:

{
  imports = [
    ./desktop.nix # Laptops include desktop features
  ];

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };

  services.thermald.enable = lib.mkDefault true;
  services.tlp = {
    enable = lib.mkDefault true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      DISK_DEVICES = "nvme0n1 sda";
      DISK_APM_LEVEL_ON_AC = "254 254";
      DISK_APM_LEVEL_ON_BAT = "128 128";
    };
  };

  # Laptop-specific services
  services.acpid.enable = true;

  # Touchpad support
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
    };
  };

  # WiFi
  networking.wireless.iwd = {
    enable = lib.mkDefault true;
    settings = {
      General = {
        EnableNetworkConfiguration = true;
      };
    };
  };

  # Backlight control
  programs.light.enable = true;

  # Auto-suspend
  services.logind = {
    # Use the new settings format for all logind options
    settings = {
      Login = {
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "ignore";
        HandlePowerKey = "suspend";
        IdleAction = "suspend";
        IdleActionSec = "15min";
      };
    };
  };
}
