# Desktop host configuration
{ inputs, ... }:

{
  imports = [
    # Hardware configuration
    ./hardware.nix

    # System profiles
    ../../modules/nixos/profiles/desktop.nix

    # Core modules
    ../../modules/nixos/core/defaults.nix
    ../../modules/nixos/core/users.nix

    # Services
    ../../modules/nixos/services/tailscale.nix
    ../../modules/nixos/services/syncthing.nix

    # Input modules
    inputs.agenix.nixosModules.age
  ];

  # Boot configuration
  boot.loader = {
    grub = {
      enable = true;
      devices = [ "/dev/sda" ]; # Adjust based on your system
      useOSProber = true;
    };
  };

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

  # Desktop-specific services
  services = {
    # Display manager
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
    };

    # Audio
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  # Gaming support
  programs.steam.enable = true;
  hardware.graphics.enable32Bit = true;

  # User configuration
  my.users = {
    mar = {
      enable = true;
      enableHome = true;
      profiles = [ "developer" "desktop" ];
      extraSystemConfig = {
        extraGroups = [ "audio" "video" "render" ];
      };
    };
  };
}
