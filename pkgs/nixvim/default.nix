{ inputs, ... }:
let
  nixvimModule = { imports = [ ./nixvim.nix ]; };

in
{
  flake.nixvimModules = {
    nixVim = nixvimModule;
  };

  perSystem = { pkgs, system, ... }: {

    checks.nixvim = inputs.nixvim.lib."${system}".check.mkTestDerivationFromNixvimModule {
      inherit pkgs; module = nixvimModule;
    };

    packages.nixvim =
      inputs.nixvim.legacyPackages."${system}".makeNixvimWithModule {
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            (_: _: { mcphub-nvim = inputs.mcphub-nvim.packages.${system}.default; })
            (_: _: { mcphub = inputs.mcphub.packages.${system}.default; })
          ];
        }
        ;
        module = nixvimModule;
      };
  };
}
