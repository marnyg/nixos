{ config, lib, ... }:
with lib;
{
  options = { };
  config = {
    plugins = {
      cmp-nvim-lua.enable = true;
      cmp_luasnip.enable = true;
      cmp-buffer.enable = true;
      cmp-calc.enable = true;
      cmp-cmdline.enable = true;
      cmp-conventionalcommits.enable = true;
      cmp-nvim-lsp.enable = lib.mkDefault (config.plugins.lsp.enable);
      cmp-nvim-lsp-signature-help.enable = lib.mkDefault (config.plugins.lsp.enable);
      cmp-nvim-lsp-document-symbol.enable = lib.mkDefault (config.plugins.lsp.enable);
      cmp-treesitter.enable = true;
      cmp-emoji.enable = true;
      cmp-spell.enable = true;
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          mapping = {
            __raw = ''
              cmp.mapping.preset.insert {
                -- Select the [n]ext item
                ['<C-n>'] = cmp.mapping.select_next_item(),
                -- Select the [p]revious item
                ['<C-p>'] = cmp.mapping.select_prev_item(),
            
                -- Scroll the documentation window [b]ack / [f]orward
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
            
                -- Accept ([y]es) the completion.
                --  This will auto-import if your LSP supports it.
                --  This will expand snippets if the LSP sent a snippet.
                ['<C-y>'] = cmp.mapping.confirm { select = true },
            
                -- Manually trigger a completion from nvim-cmp.
                --  Generally you don't need this, because nvim-cmp will display
                --  completions whenever it has completion options available.
                ['<C-Space>'] = cmp.mapping.complete {},
            
                -- Think of <c-l> as moving to the right of your snippet expansion.
                --  So if you have a snippet that's like:
                --  function $name($args)
                --    $body
                --  end
                --
                -- <c-l> will move you to the right of each of the expansion locations.
                -- <c-h> is similar, except moving you backwards.
                ['<C-l>'] = cmp.mapping(function()
                  local luasnip = require 'luasnip'
                  if luasnip.expand_or_locally_jumpable() then
                    luasnip.expand_or_jump()
                  end
                end, { 'i', 's' }),
            
                ['<C-h>'] = cmp.mapping(function()
                  local luasnip = require 'luasnip'
                  if luasnip.locally_jumpable(-1) then
                    luasnip.jump(-1)
                  end
              end, { 'i', 's' })
              }
            '';
          };
          snippet.expand = ''function(args) require('luasnip').lsp_expand(args.body) end'';

          #sorting.comparators = [
          #   "require('copilot_cmp.comparators').prioritize"
          #   "require('cmp.config.compare').offset"
          #   "require('cmp.config.compare').exact"
          #   "require('cmp.config.compare').score"
          #   "require('cmp.config.compare').recently_used"
          #   "require('cmp.config.compare').locality"
          #   "require('cmp.config.compare').kind"
          #   "require('cmp.config.compare').length"
          #   "require('cmp.config.compare').order"
          # ];

          sources = [
            { name = "neorg"; }
            (mkIf config.plugins.lsp.enable { name = "nvim_lsp"; })
            (mkIf config.plugins.lsp.enable { name = "nvim_lsp_signature_help"; })
            (mkIf config.plugins.lsp.enable { name = "nvim_lsp_document_symbol"; })
            #(mkIf config.plugins.supermaven.enable { name = "supermaven"; })
            #{ name = "copilot"; }
            { name = "luasnip"; }
            { name = "treesitter"; }
            { name = "nvim_lua"; }
            { name = "path"; }
            { name = "buffer"; }
            { name = "spell"; }
            { name = "calc"; }
            { name = "emoji"; }
            { name = "cmdline"; }
          ];
        };
      };
    };
  };

}
