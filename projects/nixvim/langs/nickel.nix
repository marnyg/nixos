{ config, pkgs, lib, ... }:
with lib;
{
  options.langs.nickel = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Nickel (configuration language) support.";
    };
    lsp.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable LSP server.";
    };
    cli.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Put the `nickel` CLI (eval, export, query) on Neovim's PATH.";
    };
  };

  config = mkIf config.langs.nickel.enable {
    # `.ncl` -> nickel is already in Neovim's builtin filetype table, and
    # nvim-lspconfig ships the nickel_ls defaults (cmd/filetypes/root_markers),
    # so enabling the server is enough. `package` defaults to `pkgs.nls`.
    extraPackages = mkIf config.langs.nickel.cli.enable [ pkgs.nickel ];

    lsp.servers.nickel_ls.enable = config.langs.nickel.lsp.enable;

    plugins.treesitter = {
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        nickel
      ];
    };
  };
}
