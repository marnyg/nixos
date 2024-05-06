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
    plugins = {

      lsp = mkIf config.langs.ocaml.lsp.enable {
        enable = true;
        servers = {
          ocamllsp.enable = true;
          # FIXME: this will only work in nvim 10 and ocaml lsp 1.8.0 
          ocamllsp.onAttach.function = ''
            client.notify('workspace/didChangeConfiguration', {
              settings = {
                inlayHints = { enable = true },
                codelens= { enable = true }
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
