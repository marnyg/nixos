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

    # Services
    ../../modules/nixos/services/tailscale.nix
    ../../modules/nixos/services/syncthing.nix

    # Input modules
    inputs.agenix.nixosModules.age
  ];

  # System configuration
  system.stateVersion = "23.11";

  # Enable modules
  myModules = {
    defaults.enable = true;
  };

  # Age secrets configuration
  age = {
    secrets = {
      openrouterToken = {
        file = ../../modules/home/secrets/claudeToken.age;
        owner = "mar";
      };
      claudeToken = {
        file = ../../modules/home/secrets/claudeToken.age;
        owner = "mar";
      };
    };
    identityPaths = [ "/home/mar/.ssh/id_ed25519" ];
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
