{ config, pkgs, lib, ... }:
with lib;
{
  options = { };
  config = {
    plugins = {
      ts-context-commentstring.enable = true;
      treesitter-textobjects = {
        enable = true;
        settings = {
          select = {
            enable = true;
            lookahead = true;
            keymaps = {
              "af" = "@function.outer";
              "if" = "@function.inner";
              "il" = "@loop.outer";
              "al" = "@loop.outer";
              "icd" = "@conditional.inner";
              "acd" = "@conditional.outer";
              "acm" = "@comment.outer";
              "ast" = "@statement.outer";
              "isc" = "@scopename.inner";
              "iB" = "@block.inner";
              "aB" = "@block.outer";
              "p" = "@parameter.inner";
            };
          };

          move = {
            enable = true;
            set_jumps = true;
            goto_next_start = {
              "gnf" = "@function.outer";
              "gnif" = "@function.inner";
              "gnp" = "@parameter.inner";
              "gnc" = "@call.outer";
              "gnic" = "@call.inner";
            };
            goto_next_end = {
              "gnF" = "@function.outer";
              "gniF" = "@function.inner";
              "gnP" = "@parameter.inner";
              "gnC" = "@call.outer";
              "gniC" = "@call.inner";
            };
            goto_previous_start = {
              "gpf" = "@function.outer";
              "gpif" = "@function.inner";
              "gpp" = "@parameter.inner";
              "gpc" = "@call.outer";
              "gpic" = "@call.inner";
            };
            goto_previous_end = {
              "gpF" = "@function.outer";
              "gpiF" = "@function.inner";
              "gpP" = "@parameter.inner";
              "gpC" = "@call.outer";
              "gpiC" = "@call.inner";
            };
          };
          lsp_interop.enable = lib.mkDefault (config.plugins.lsp.enable);
        };
      };
      treesitter = {
        enable = true;
        settings.indent.enable = true;
        settings.incremental_selection.enable = true;
        settings.highlight.enable = true;
        folding = true;
        nixvimInjections = true;
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
          c # c is implicit dependency, not specifying it will lead to healtcheck errors
          c_sharp
          diff
          git_config
          git_rebase
          gitattributes
          gitcommit
          gitignore
          json
          lua
          luadoc
          make
          markdown # dep of noice
          markdown_inline # dep of noice
          nix
          query # implicit
          regex
          toml
          vim
          vimdoc
          xml
          yaml
          #TODO: wait for unstable to add this
          #norg
          terraform
        ];
      };
      treesitter-context.enable = true;
    };
  };

}
