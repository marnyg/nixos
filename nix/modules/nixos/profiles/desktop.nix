# Desktop system profile
{ lib, pkgs, ... }:

{
  # Enable X11/Wayland
  services.xserver = {
    enable = lib.mkDefault true;
    displayManager.gdm.enable = lib.mkDefault true;
    desktopManager.gnome.enable = lib.mkDefault false;
  };

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Graphics drivers
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Printing
  services.printing.enable = lib.mkDefault true;

  # Network manager for GUI
  networking.networkmanager.enable = lib.mkDefault true;

  # Enable CUPS for printing
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = lib.mkDefault true;
  services.blueman.enable = lib.mkDefault true;

  # Power management
  services.upower.enable = true;

  # Common desktop packages
  environment.systemPackages = with pkgs; [
    firefox
    pavucontrol
    networkmanagerapplet
  ];
}
