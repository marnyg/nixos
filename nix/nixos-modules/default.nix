{ self, inputs, ... }:
{
  flake.nixosModules = rec {
    default = {
      imports = [
        tailscale
        wsl
        syncthingService
        users
        defaults
        myHomemanagerModules
        self.inputs.home-manager.nixosModules.home-manager
        self.inputs.nixos-wsl.nixosModules.wsl
        inputs.nur.nixosModules.nur
        inputs.microvm.nixosModules.host
      ];
    };
    tailscale = ./tailscaleService.nix;
    wsl = ./wsl.nix;
    syncthingService = ./syncthingService.nix;
    users = ./users.nix;
    defaults = ./defaults.nix;

    nur = inputs.nur.nixosModules.nur;
    myHomemanagerModules = { lib, ... }: { home-manager.sharedModules = lib.attrValues self.homemanagerModules; };
  };
}
