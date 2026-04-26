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
            # FIXME: remove once nixvim sets pname on its nvim-config plugin
            # https://github.com/nix-community/nixvim/issues — packDir now requires pname on all plugins
            (_: prev: {
              vimUtils = prev.vimUtils // {
                packDir = packages:
                  let
                    addPname = p: if p ? pname then p else p // { pname = p.name or "unknown"; };
                    fixPkg = _: val: val // {
                      start = map addPname (val.start or [ ]);
                      opt = map addPname (val.opt or [ ]);
                    };
                  in
                  prev.vimUtils.packDir (builtins.mapAttrs fixPkg packages);
              };
            })
          ];
        }
        ;
        module = nixvimModule;
      };
  };
}
