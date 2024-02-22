{ ... }:
{
  flake.nixosModules = rec {
    default = {
      imports = [
        tailscale
        homemanager
        wsl
        syncthingService
        users
      ];
    };
    tailscale = ./tailscaleService.nix;
    homemanager = ./my-homemanager.nix;
    wsl = ./wsl.nix;
    syncthingService = ./syncthingService.nix;
    users = ./users.nix;
  };
}
