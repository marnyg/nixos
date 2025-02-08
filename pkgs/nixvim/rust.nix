{ config, pkgs, lib, ... }:
with lib;
{
  options.langs.rust = {
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

  config = mkIf config.langs.rust.enable {
    plugins = {

      lsp = mkIf config.langs.rust.lsp.enable {
        enable = true;
        servers = {
          rust_analyzer.enable = true;
        };
      };

      treesitter = {
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          rust
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
