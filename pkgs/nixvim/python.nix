{ config, pkgs, lib, ... }:
with lib;
{
  options.langs.python = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Python development support.";
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

  config = mkIf config.langs.python.enable {
    plugins = {
      lsp = mkIf config.langs.python.lsp.enable {
        enable = true;
        servers = {
          pyright = {
            enable = true;
            settings = {
              python = {
                analysis = {
                  typeCheckingMode = "basic";
                  inlayHints = {
                    enable = true;
                    variableTypes = true;
                    functionReturnTypes = true;
                  };
                };
              };
            };
          };
          ruff = {
            enable = true;
            settings = {
              organizeImports = true;
              fixAll = true;
            };
          };
        };
      };

      treesitter = {
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          python
        ];
      };

      # dap = mkIf config.langs.python.dap.enable {
      #   enable = true;
      #   adapters = {
      #     python = {
      #       type = "executable";
      #       command = "${pkgs.python3Packages.debugpy}/bin/python";
      #       args = [ "-m" "debugpy.adapter" ];
      #     };
      #   };
      #   configurations = {
      #     python = [
      #       {
      #         type = "python";
      #         request = "launch";
      #         name = "Launch file";
      #         program = "\${file}";
      #         pythonPath = "\${command:python.interpreterPath}";
      #       }
      #     ];
      #   };
      #   extensions = {
      #     dap-ui.enable = true;
      #     dap-virtual-text.enable = true;
      #   };
      # };
    };
  };
}

