# WSL host configuration
{ inputs, pkgs, ... }:

{
  imports = [
    # System profiles
    ../../modules/nixos/profiles/wsl.nix

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
    wsl.enable = true;
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

  # Nix settings
  nix.settings.trusted-users = [ "root" "mar" ];

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
    notHM = {
      enable = true;
      enableHome = false;
    };
  };
}
