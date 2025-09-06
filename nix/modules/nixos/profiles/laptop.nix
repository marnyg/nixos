# Laptop system profile
{ lib, ... }:

{
  imports = [
    ./desktop.nix # Laptops include desktop features
    ../hardware/laptop-power.nix # Laptop-specific power management
  ];

  # CORE: Essential laptop features

  # Laptop power management is essential
  hardware.profiles.laptopPower = {
    enable = true; # Power management is mandatory for laptops
    cpuFreqGovernor = lib.mkDefault "powersave"; # Can be changed for performance
    enableTlp = lib.mkDefault true; # TLP is recommended but can be replaced
    batteryThresholds = {
      start = lib.mkDefault 75; # Can be customized per user preference
      stop = lib.mkDefault 80;
    };
  };

  # Bluetooth power optimization for laptops
  hardware.profiles.bluetooth.powerOnBoot = lib.mkForce false; # Force off to save battery

  # Touchpad support is essential for laptops
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
    };
  };

  # WiFi is essential for laptops
  networking.wireless.iwd = {
    enable = true; # Laptops must have WiFi
    settings = {
      General = {
        EnableNetworkConfiguration = true;
      };
    };
  };
}
