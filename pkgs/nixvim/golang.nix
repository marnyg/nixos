{ config, pkgs, lib, ... }:
with lib;
{
  options.langs.golang = {
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

  config = mkIf config.langs.golang.enable {
    plugins = {

      lsp = mkIf config.langs.golang.lsp.enable {
        enable = true;
        servers = {
          gopls.enable = true;
        };
      };

      treesitter = {
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          go
          gomod
          gosum
          gotmpl
          gowork
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
