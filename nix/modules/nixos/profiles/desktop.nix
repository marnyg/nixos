# Desktop system profile
# Contains common settings for desktop systems
{ lib, pkgs, ... }:

{
  # Graphics drivers
  hardware.graphics = {
    enable = lib.mkDefault true;
    enable32Bit = lib.mkDefault true;
  };

  # Audio - keep these as defaults since they're common
  security.rtkit.enable = lib.mkDefault true;
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = lib.mkDefault true;
    alsa.support32Bit = lib.mkDefault true;
    pulse.enable = lib.mkDefault true;
    wireplumber.enable = lib.mkDefault true;
  };

  # Bluetooth - common for desktops
  hardware.bluetooth.enable = lib.mkDefault true;
  hardware.bluetooth.powerOnBoot = lib.mkDefault false;
  services.blueman.enable = lib.mkDefault true;

  # Network manager for GUI
  networking.networkmanager.enable = lib.mkDefault true;

  # Power management
  services.upower.enable = lib.mkDefault true;

  # Printing support
  services.printing.enable = lib.mkDefault true;
  services.avahi = {
    enable = lib.mkDefault true;
    nssmdns4 = lib.mkDefault true;
  };

  # Common desktop packages
  environment.systemPackages = with pkgs; [
    firefox
    pavucontrol
    networkmanagerapplet
  ];
}
