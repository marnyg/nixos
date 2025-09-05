# Laptop host configuration
{ inputs, ... }:

{
  imports = [
    # Hardware configuration
    ./hardware.nix

    # System profiles
    ../../modules/nixos/profiles/laptop.nix

    # Core modules
    ../../modules/nixos/core/defaults.nix
    ../../modules/nixos/core/users.nix
    ../../modules/nixos/core/secrets.nix
    ../../modules/nixos/core/nix-settings.nix

    # Services
    ../../modules/nixos/services/tailscale.nix
    ../../modules/nixos/services/syncthing.nix

    # Input modules
    inputs.agenix.nixosModules.age
  ];

  # Boot configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # System configuration
  system.stateVersion = "23.11";

  # Enable modules
  myModules = {
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
