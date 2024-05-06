{ config, pkgs, lib, ... }:
with lib;
{
  options.langs.terraform = {
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

  config = mkIf config.langs.terraform.enable {
    plugins = {

      lsp = mkIf config.langs.terraform.lsp.enable {
        enable = true;
        servers = {
          terraformls.enable = true;
        };
      };

      treesitter = {
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          terraform
        ];
      };

    };
  };
}
