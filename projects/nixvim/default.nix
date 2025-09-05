{ inputs, ... }:
let
  nixvimModule = { imports = [ ./nixvim.nix ]; };

in
{
  # Note: nixvimModules removed as it's not a standard flake output
  # The module is used directly in checks and packages below

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
