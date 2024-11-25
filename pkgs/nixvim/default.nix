{ inputs, self, ... }:
let
  nixvimModule = { imports = [ ./nixvim.nix ]; };
in
{
  flake.nixvimModules = {
    nixVim = nixvimModule;
  };
  # flake.HomemanagerModules.nixvim = { pkgs, ... }: {
  #   programs.nixvim.enable = true;
  #   programs.nixvim.pkgs = self.packages.${pkgs.system}.nixvim;
  # };

  flake.nixosModules =
    let
      nixosModule =
        { lib, config, pkgs, ... }: with lib; {
          imports = [ inputs.nixvim.nixosModules.nixvim ];
          options.myModules.myNixvim.enable = mkOption { type = types.bool; default = false; };

          config = mkIf config.myModules.myNixvim.enable {
            # zsh.extraConfig = ''
            #   export ANTHROPIC_API_KEY= $(cat ${config.age.secrets.claudeToken.path});
            # '';
            environment.systemPackages = [ self.packages.${pkgs.system}.nixvim ];
          };
        };
    in
    {
      default = { imports = [ nixosModule ]; };
      nixvim = nixosModule;
    };

  perSystem = { pkgs, system, ... }: {
    checks.nixvim = inputs.nixvim.lib."${system}".check.mkTestDerivationFromNixvimModule {
      inherit pkgs; module = nixvimModule;
    };

    packages.nixvim =
      inputs.nixvim.legacyPackages."${system}".makeNixvimWithModule {
        inherit pkgs; module = nixvimModule;
      };
  };
}
