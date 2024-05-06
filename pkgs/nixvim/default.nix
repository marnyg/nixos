{ inputs, self, ... }:
let
  nixvimModule = { imports = [ ./nixvim.nix ]; };
in
{
  flake.nixvimModules = {
    nixVim = nixvimModule;
  };
  flake.HomemanagerModules =
    let
      homemanagerModule = { config, pkgs, ... }: {
        home-manager.users.juuso.programs.nixvim =
          let neovim = (import ./nixvim.nix) { inherit config pkgs; };
          in with neovim.config; {
            inherit colorschemes extraConfigVim extraConfigLua extraPackages plugins extraPlugins;
            enable = true;
            viAlias = true;
            vimAlias = true;
            defaultEditor = true;
          };
        home-manager.users.juuso.editorconfig = {
          enable = true;
          settings = {
            "*" = {
              charset = "utf-8";
              end_of_line = "lf";
              trim_trailing_whitespace = true;
              insert_final_newline = false;
              max_line_width = 78;
              indent_style = "space";
              indent_size = 2;
            };
          };
        };
      };
    in
    {
      # default = { imports = [ nixosModule ]; };
      nixvim = homemanagerModule;
    };
  flake.nixosModules =
    let
      nixosModule =
        { lib, config, pkgs, ... }: with lib; {
          # tmp fix for broken neorg, see: 
          #  https://github.com/NixOS/nixpkgs/pull/302442
          #  https://github.com/nix-community/nixvim/issues/1395
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.neorg-overlay.overlays.default
              inputs.neovim-nightly-overlay.overlays.default
            ];
          };
          # end tmp

          imports = [ inputs.nixvim.nixosModules.nixvim ];

          options.myModules.myNixvim = {
            enable = mkOption { type = types.bool; default = false; };
          };

          config = mkIf config.myModules.myNixvim.enable {
            environment.systemPackages = [ self.packages.${pkgs.system}.nixvim ];

          };
        };
    in
    {
      default = { imports = [ nixosModule ]; };
      nixvim = nixosModule;
    };

  perSystem = { pkgs, system, ... }: {

    # tmp fix for broken neorg, see: 
    #  https://github.com/NixOS/nixpkgs/pull/302442
    #  https://github.com/nix-community/nixvim/issues/1395
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.neorg-overlay.overlays.default
        inputs.neovim-nightly-overlay.overlays.default
      ];
    };
    # end tmp

    checks.nixvim = inputs.nixvim.lib."${system}".check.mkTestDerivationFromNixvimModule {
      inherit pkgs;
      module = nixvimModule;
    };

    packages.nixvim =
      inputs.nixvim.legacyPackages."${system}".makeNixvimWithModule {
        inherit pkgs; module = nixvimModule;
      };
  };
}
