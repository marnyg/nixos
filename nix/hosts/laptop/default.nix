# Laptop host configuration
{ ... }:

{
  imports = [
    # Hardware configuration is still local
    ./hardware.nix
  ];

  # Boot configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # System configuration
  system.stateVersion = "23.11";

  # Enable modules
  modules.my = {
    defaults.enable = true;
    secrets.enable = true;
    nixSettings.enable = true;
  };

  # Laptop-specific configuration
  hardware = {
    # Enable bluetooth
    bluetooth.enable = true;

    # Battery optimization
    acpilight.enable = true;
  };

  # Power management
  services = {
    # TLP for battery optimization
    tlp.enable = true;

    # Thermal management
    thermald.enable = true;
  };

  # Network management
  networking.networkmanager.enable = true;

  # User configuration
  my.users = {
    mar = {
      enable = true;
      enableHome = true;
      profiles = [ "developer" "desktop" ];
      extraSystemConfig = {
        extraGroups = [ "networkmanager" "audio" "video" "render" ];
      };
    };
  };
}
