{ config, pkgs, lib, ... }:
with lib;
{
  options.langs.ocaml = {
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

  config = mkIf config.langs.ocaml.enable {
    globals = {
      codelens_enabled = true;
    };
    autoCmd = [
      {
        event = [ "BufEnter" "CursorHold" "InsertLeave" ];
        pattern = "*.ml";
        callback = {
          __raw = ''
            function()
              if vim.g.codelens_enabled then
                vim.lsp.codelens.refresh({ bufnr = 0}) 
              else
                vim.lsp.codelens.clear()
              end
            end
          '';
        };
      }
    ];

    keymaps = [
      # toggle codelens
      {
        action = {
          __raw = "function() vim.g.codelens_enabled = not (vim.g.codelens_enabled or false) end";
        };
        key = "<leader>cl";
        options = {
          silent = true;
          desc = "Toggle [C]ode[L]ens";
        };
      }
    ];
    plugins = {

      lsp = mkIf config.langs.ocaml.lsp.enable {
        enable = true;
        servers = {
          ocamllsp.enable = true;
          ocamllsp.package = null;
          ocamllsp.onAttach.function = ''
            client.notify('workspace/didChangeConfiguration', {
              settings = {
                codelens= { enable = true },
              }
            })
          '';
        };
      };

      treesitter = {
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          ocaml
          ocaml_interface
        ];
      };

      dap = mkIf config.langs.ocaml.dap.enable {
        enable = true;
        adapters.executables.ocamlearlybird = {
          command = "${pkgs.ocamlPackages.earlybird}/bin/ocamlearlybird";
          args = [ "debug" ];
        };
        extensions = {
          dap-ui.enable = true;
          dap-virtual-text.enable = true;
        };
      };
    };
  };
}
