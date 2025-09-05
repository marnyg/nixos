# WSL host configuration
{ inputs, pkgs, ... }:

{
  imports = [
    # System profiles
    ../../modules/nixos/profiles/wsl.nix

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

  # System configuration
  system.stateVersion = "23.11";

  # Enable modules
  myModules = {
    wsl.enable = true;
    defaults.enable = true;
    secrets.enable = true;
    nixSettings.enable = true;
  };

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # For VSCode server
  programs.nix-ld.enable = true;

  # Yubikey support
  services.udev.packages = [ pkgs.yubikey-personalization ];
  security.pam.yubico = {
    enable = true;
    mode = "challenge-response";
  };

  # Container support
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Nix settings are handled by the shared module

  # User configuration
  my.users = {
    mar = {
      enable = true;
      enableHome = true;
      profiles = [ "developer" ];
    };
    testUser = {
      enable = true;
      enableHome = true;
      profiles = [ "minimal" ];
    };
  };
}
