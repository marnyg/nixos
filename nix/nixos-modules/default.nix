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
        inputs.nur.modules.nixos.default
        inputs.microvm.nixosModules.host
      ];
    };
    tailscale = ./tailscaleService.nix;
    wsl = ./wsl.nix;
    syncthingService = ./syncthingService.nix;
    users = ./users.nix;
    defaults = ./defaults.nix;

    nur = inputs.nur.modules.nixos.default;
    myHomemanagerModules = { ... }: { home-manager.sharedModules = [ ]; };
  };
}
