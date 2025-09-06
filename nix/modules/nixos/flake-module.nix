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
    profile-laptop = ./profiles/laptop.nix;
    profile-minimal = ./profiles/minimal.nix;
    profile-wsl = ./profiles/wsl.nix;

    # Hardware modules
    hardware-audio = ./hardware/audio.nix;
    hardware-bluetooth = ./hardware/bluetooth.nix;
    hardware-laptop-power = ./hardware/laptop-power.nix;
    hardware-nvidia = ./hardware/nvidia.nix;

    # Service modules
    service-syncthing = ./services/syncthing.nix;
    service-tailscale = ./services/tailscale.nix;
  };
}

