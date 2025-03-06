{ config, pkgs, lib, ... }:
with lib;
{
  options.langs.gleam = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable DAP plugins for debugging.";
    };
    lsp.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable LSP server.";
    };
    dap.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable DAP plugins for debugging.";
    };
  };

  config = mkIf config.langs.gleam.enable {
    plugins = {

      lsp = mkIf config.langs.gleam.lsp.enable {
        enable = true;
        servers = {
          gleam.enable = true;
          gleam.package = null;
        };
      };

      treesitter = {
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          gleam
        ];
      };

      # dap = mkIf config.langs.ocaml.dap.enable {
      #   enable = true;
      #   adapters.executables.ocamlearlybird = {
      #     command = "${pkgs.ocamlPackages.earlybird}/bin/ocamlearlybird";
      #     args = [ "debug" ];
      #   };
      # };
    };
  };
}
