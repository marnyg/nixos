{ ... }:
{
  flake.nixosModules = {
    # Core modules
    core-defaults = ./core/defaults.nix;
    core-imports = ./core/imports.nix;
    core-nixSettings = ./core/nix-settings.nix;
    core-secrets = ./core/secrets.nix;
    core-users = ./core/users.nix;

    # Profile modules
    profile-desktop = ./profiles/desktop.nix;
    profile-minimal = ./profiles/minimal.nix;
    profile-wsl = ./profiles/wsl.nix;

    # Service modules
    service-syncthing = ./services/syncthing.nix;
    service-tailscale = ./services/tailscale.nix;
  };
}

