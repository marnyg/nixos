{ config, pkgs, ... }:
{
  options = { };
  config = {
    plugins = {
      lsp = {
        enable = true;
        servers = {
          ocamllsp.enable = true;
        };
      };
      treesitter = {
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          ocaml
          ocaml_interface
        ];
      };
    };
  };
}
