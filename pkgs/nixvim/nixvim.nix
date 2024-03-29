{ config, pkgs, ... }: {
  options = { };

  imports = [ ./langs.nix ];

  config = {
    options = {
      relativenumber = true; # Show relative line numbers
      updatetime = 250;
      timeoutlen = 300;
      foldlevel = 20;
    };

    globals = { };
    colorschemes.catppuccin = { enable = true; };

    extraConfigLua = ''
      local map = vim.keymap.set
      -- better indenting
      map("v", ">", ">gv", { noremap = true, silent = true })
      map("v", "<", "<gv", { noremap = true, silent = true })

      -- Move selected line / block of text in visual mode
      map("x", "K", ":move '<-2<CR>gv-gv", { noremap = true, silent = true })
      map("x", "J", ":move '>+1<CR>gv-gv", { noremap = true, silent = true })

      map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
      map('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
      map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
      map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
      map('n', '<leader>.', ":e %:p:h<CR>", { desc = 'Open folder of current file' })
      map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

      vim.notify = require('mini.notify').make_notify()
    '';

    extraPackages = with pkgs; [
      fd
      gcc
      nixpkgs-fmt
      ripgrep
      shellcheck
    ];

    plugins = {
      lsp = {
        enable = true;
        servers = {
          bashls.enable = true;
          nixd.enable = true;
        };
      };
      # lsp-format.enable = true;
      conform-nvim.enable = true;
      copilot-lua = {
        enable = true;
      };

      friendly-snippets.enable = true;

      # gitsigns.enable = true;

      indent-blankline = {
        enable = true;
        scope = {
          enabled = true;
          showStart = true;
        };
      };

      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
        extensions.ui-select.enable = true;
        keymaps = {
          #"<C-p>" = { action = "git_files"; desc = "Telescope Git Files"; };
          "<leader>sh" = { action = "help_tags"; desc = "[S]earch [H]elp"; };
          "<leader>sk" = { action = "keymaps"; desc = "[S]earch [K]eymaps"; };
          "<leader>sf" = { action = "find_files"; desc = "[S]earch [F]iles"; };
          "<leader>ss" = { action = "builtin"; desc = "[S]earch [S]elect Telescope"; };
          "<leader>sw" = { action = "grep_string"; desc = "[S]earch current [W]ord"; };
          "<leader>sg" = { action = "live_grep"; desc = "[S]earch by [G]rep"; };
          "<leader>sd" = { action = "diagnostics"; desc = "[S]earch [D]iagnostics"; };
          "<leader>sr" = { action = "resume"; desc = "[S]earch [R]esume"; };
          "<leader>s." = { action = "oldfiles"; desc = "[S]earch Recent Files (\".\" for repeat)"; };
          "<leader><leader>" = { action = "buffers"; desc = "[ ] Find existing buffers"; };
        };
        # extraOptionst='' '';
      };
      treesitter-textobjects = {
        enable = true;
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
          setJumps = true;
          gotoNextStart = {
            "gnf" = "@function.outer";
            "gnif" = "@function.inner";
            "gnp" = "@parameter.inner";
            "gnc" = "@call.outer";
            "gnic" = "@call.inner";
          };
          gotoNextEnd = {
            "gnF" = "@function.outer";
            "gniF" = "@function.inner";
            "gnP" = "@parameter.inner";
            "gnC" = "@call.outer";
            "gniC" = "@call.inner";
          };
          gotoPreviousStart = {
            "gpf" = "@function.outer";
            "gpif" = "@function.inner";
            "gpp" = "@parameter.inner";
            "gpc" = "@call.outer";
            "gpic" = "@call.inner";
          };
          gotoPreviousEnd = {
            "gpF" = "@function.outer";
            "gpiF" = "@function.inner";
            "gpP" = "@parameter.inner";
            "gpC" = "@call.outer";
            "gpiC" = "@call.inner";
          };
        };
        lspInterop.enable = true;
      };
      treesitter = {
        enable = true;
        indent = true;
        folding = true;
        nixvimInjections = true;
        incrementalSelection.enable = true;
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
          norg
        ];
      };
      treesitter-context.enable = true;
      fidget.enable = true;
      oil = {
        enable = true;
        keymaps = {
          "<C-l>" = false;
          "<C-h>" = false;
          "<C-s>" = false;
          "<C-r>" = "actions.refresh";
          "y." = "actions.copy_entry_path";
        };
      };
      todo-comments.enable = true;
      tmux-navigator.enable = true;
      mini = {
        enable = true;
        modules = {
          ai = { n_lines = 500; };
          surround = { };
          trailspace = { };
          notify = { };
          comment = { };
          statusline = { };
          basics = {
            options.extra_ui = true;
            mappings.windows = true;
          };
          # indentscope={ };
        };
      };

      neorg = {
        enable = true;
        modules = {
          "core.defaults" = { };
          "core.concealer".config.icon_preset = "diamond";
          "core.dirman".config.workspaces.notes = "~/git/notes";
          "core.keybinds".config.default_keybinds = true;
          "core.completion".config = { engine = "nvim-cmp"; };
        };

      };


      luasnip = {
        enable = true;
        extraConfig.enable_autosnippets = true;
      };
      cmp-nvim-lua.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp_luasnip.enable = true;
      cmp-buffer.enable = true;
      cmp-calc.enable = true;
      cmp-cmdline.enable = true;
      cmp-conventionalcommits.enable = true;
      cmp-nvim-lsp-signature-help.enable = true;
      cmp-nvim-lsp-document-symbol.enable = true;
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
          sources = [
            { name = "buffer"; }
            { name = "calc"; }
            { name = "luasnip"; }
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "cmdline"; }
            { name = "neorg"; }
            { name = "emoji"; }
            { name = "nvim_lua"; }
            { name = "spell"; }
            { name = "treesitter"; }
            { name = "nvim_lsp_document_symbol"; }
            { name = "nvim_lsp_signature_help"; }
          ];
        };
      };
    };
    # TODO:
    # extraPlugins = with pkgs.vimPlugins; [
    #   dadbod?
    #   dbee?
    #    {
    #      plugin = boole-nvim;
    #      config = '' 
    #        lua <<EOF
    #        require('boole').setup({
    #          mappings = {
    #            increment = '<C-a>',
    #            decrement = '<C-x>'
    #          },
    #          -- User defined loops
    #          additions = { },
    #          allow_caps_additions = { }
    #        })
    #          
    #        EOF
    #      '';
    #    }
    # ];
  };
}
