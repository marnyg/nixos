{ config, pkgs, lib, ... }:
with lib;
{
  options.langs.elixir = {
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

  config = mkIf config.langs.elixir.enable {
    plugins = {

      lsp = mkIf config.langs.elixir.lsp.enable {
        enable = true;
        servers = {
          elixirls.enable = true;
        };
      };

      treesitter = {
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          elixir
        ];
      };

      # dap = mkIf config.langs.elixir.dap.enable {
      #   enable = true;
      # };
    };
  };
}
