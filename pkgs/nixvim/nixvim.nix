{ config, pkgs, ... }: {
  options = { };

  imports = [ ./langs.nix ./ocaml.nix ];

  config = {
    opts = {
      relativenumber = true; # Show relative line numbers
      updatetime = 250;
      timeoutlen = 300;
      foldlevel = 20;
      conceallevel = 2;
    };
    autoCmd = [
      {
        event = [ "BufEnter" "BufWinEnter" ];
        pattern = [ "*.norg" ];
        command = ''
          	set spell
          	set tw=101
          	'';
      }
      {
        event = [ "BufLeave" "BufWinLeave" ];
        pattern = [ "*.norg" ];
        command = ''
          	set nospell
          	set tw=0
          	'';
      }
    ];

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
      lsp-format.enable = true;
      lspkind = {
        enable = true;
        symbolMap = {
          Copilot = "";
        };
      };

      conform-nvim.enable = true;
      copilot-cmp = {
        enable = true;
      };
      copilot-lua = {
        enable = true;
        suggestion.enabled = false;
        panel.enabled = false;
      };

      friendly-snippets.enable = true;

      gitsigns.enable = true;

      indent-blankline = {
        enable = true;
        settings.scope = {
          enabled = true;
          show_start = true;
        };
      };

      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
        extensions.ui-select.enable = true;
        extensions.frecency.enable = true;
        extensions.media-files.enable = true;
        extensions.undo.enable = true;
        keymaps = {
          #"<C-p>" = { action = "git_files"; desc = "Telescope Git Files"; };
          "<leader>sh" = { action = "help_tags"; options.desc = "[S]earch [H]elp"; };
          "<leader>sk" = { action = "keymaps"; options.desc = "[S]earch [K]eymaps"; };
          "<leader>sf" = { action = "find_files"; options.desc = "[S]earch [F]iles"; };
          # "<leader>ff" = { action = "frecency"; desc = "[F]recuant [F]iles"; };
          # "<leader>su" = { action = "undo"; desc = "[S]earch [U]ndo"; };
          "<leader>ss" = { action = "builtin"; options.desc = "[S]earch [S]elect Telescope"; };
          "<leader>sw" = { action = "grep_string"; options.desc = "[S]earch current [W]ord"; };
          "<leader>sg" = { action = "live_grep"; options.desc = "[S]earch by [G]rep"; };
          "<leader>sd" = { action = "diagnostics"; options.desc = "[S]earch [D]iagnostics"; };
          "<leader>sr" = { action = "resume"; options.desc = "[S]earch [R]esume"; };
          "<leader>s." = { action = "oldfiles"; options.desc = "[S]earch Recent Files (\".\" for repeat)"; };
          "<leader><leader>" = { action = "buffers"; options.desc = "[ ] Find existing buffers"; };
        };
        # extraOptionst='' '';
      };

      ts-context-commentstring.enable = true;
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
          terraform
        ];
      };
      treesitter-context.enable = true;
      fidget.enable = true;
      harpoon = {
        enable = true;
        enableTelescope = true;
        keymaps = {
          toggleQuickMenu = "<leader>h";
          addFile = "<leader>a";
          navFile = {
            "1" = "<leader>1";
            "2" = "<leader>2";
            "3" = "<leader>3";
            "4" = "<leader>4";
          };
          gotoTerminal = {
            "1" = "<leader>!";
            "2" = "<leader>@";
            "3" = "<leader>#";
            "4" = "<leader>$";
          };
        };

        # vim.keymap.set("n", "<leader>a", mark.add_file)
        # vim.keymap.set("n", "<leader>h", ui.toggle_quick_menu)
        #
        # vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end)
        # vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end)
        # vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end)
        # vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end)

      };
      oil = {
        enable = true;
        settings.keymaps = {
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
          "core.integrations.telescope".config = { };
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
          sorting.comparators = [
            "require('copilot_cmp.comparators').prioritize"
            "require('cmp.config.compare').offset"
            "require('cmp.config.compare').exact"
            "require('cmp.config.compare').score"
            "require('cmp.config.compare').recently_used"
            "require('cmp.config.compare').locality"
            "require('cmp.config.compare').kind"
            "require('cmp.config.compare').length"
            "require('cmp.config.compare').order"
          ];
          sources = [
            { name = "neorg"; }
            { name = "copilot"; }
            { name = "nvim_lsp"; }
            { name = "nvim_lsp_signature_help"; }
            { name = "nvim_lsp_document_symbol"; }
            { name = "luasnip"; }
            { name = "treesitter"; }
            { name = "nvim_lua"; }
            { name = "path"; }
            { name = "buffer"; }
            { name = "spell"; }
            { name = "calc"; }
            { name = "emoji"; }
            # { name = "cmdline"; } #breacs neorg
          ];
        };
      };
    };
    extraPlugins = with pkgs.vimPlugins; [
      lazygit-nvim # TODO: add keybindings for opening lazygit
      vim-dadbod
      neorg-telescope
      vim-dadbod-ui # TODO: add keybindings for opening dbui
      {
        plugin = boole-nvim;
        config = '' 
           lua <<EOF
           require('boole').setup({
             mappings = {
               increment = '<C-a>',
               decrement = '<C-x>'
             },
             -- User defined loops
             additions = { },
             allow_caps_additions = { }
           })
             
           EOF
         '';
      }
    ];
  };
}
