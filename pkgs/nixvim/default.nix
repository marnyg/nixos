{ inputs, ... }:
{
  flake.nixosModules =
    let
      nixosModule = {
        imports = [ inputs.nixvim.nixosModules.nixvim ];
        # programs.nixvim.enable = true;
        programs.nixvim = import ./nixvim.nix;
      };



      homemanagerModule = { inputs, outputs, nixpkgs, config, lib, pkgs, ... }: {
        home-manager.users.juuso.programs.nixvim = let neovim = (import ./nixvim.nix) { inherit config pkgs; }; in with neovim.config; {
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
      default = { imports = [ nixosModule ]; };
      nixvim = nixosModule;
    };

  perSystem = { pkgs, system, ... }: {
    packages.nixvim =
      inputs.nixvim.legacyPackages."${system}".makeNixvimWithModule {
        inherit pkgs;
        module = {
          imports = [
            # inputs.juuso.outputs.nixosModules.neovim
            ./nixvim.nix
          ];
          plugins.lightline.enable = true;
        };
      };
    # (
    # inputs.nixvim.legacyPackages."${system}".makeNixvim (import ./nixvim.nix)
    # );
  };
}
