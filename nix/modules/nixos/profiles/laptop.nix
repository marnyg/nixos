# Laptop system profile
{ lib, ... }:

{
  imports = [
    ./desktop.nix # Laptops include desktop features
    ../hardware/laptop-power.nix # Laptop-specific power management
  ];

  # Enable laptop power management
  hardware.profiles.laptopPower = {
    enable = lib.mkDefault true;
    cpuFreqGovernor = lib.mkDefault "powersave";
    enableTlp = lib.mkDefault true;
    batteryThresholds = {
      start = lib.mkDefault 75;
      stop = lib.mkDefault 80;
    };
  };

  # Bluetooth typically off on boot for laptops to save power
  hardware.profiles.bluetooth.powerOnBoot = lib.mkForce false;

  # Touchpad support
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
    };
  };

  # WiFi with power management
  networking.wireless.iwd = {
    enable = lib.mkDefault true;
    settings = {
      General = {
        EnableNetworkConfiguration = true;
      };
    };
  };
}
