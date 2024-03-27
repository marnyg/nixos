{ config, pkgs, ... }: {
  # enable =true;
  options = { };

  imports = [ ./langs.nix ];

  config = {
    options = {
      relativenumber = true; # Show relative line numbers
      # cursorline = true;
      # laststatus = 2;
      # shiftwidth = 2; # Tab width should be 2
      updatetime = 250;
      timeoutlen = 300;
    };
    globals = {
      # mapleader = "\\";
      # nobackup = true;
      # noswapfile = true;
    };
    colorschemes.catppuccin = {
      enable = true;
    };
    extraConfigVim = ''
    '';
    extraConfigLua = ''
      local map = vim.keymap.set
      -- better indenting
      map("v", ">", ">gv", { noremap = true, silent = true })
      map("v", "<", "<gv", { noremap = true, silent = true })

      -- Move selected line / block of text in visual mode
      map("x", "K", ":move '<-2<CR>gv-gv", { noremap = true, silent = true })
      map("x", "J", ":move '>+1<CR>gv-gv", { noremap = true, silent = true })

      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
      vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

      vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
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
      # conform-nvim.formatOnSave='' 
      # '';
      luasnip.enable = true;
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
          "<leader>ff" = "find_files";
          "<C-p>" = {
            action = "git_files";
            desc = "Telescope Git Files";
          };
          "<leader>fg" = "live_grep";
          # map("n", "<leader>ff", "<cmd>Telescope git_files<cr>", { noremap = true, silent = true })
          # map("n", "<leader>fp", "<cmd>Telescope projects<cr>", { noremap = true, silent = true })
          # map("n", "<leader>fsa", "<cmd>Telescope live_grep<cr>", { noremap = true, silent = true })
          # map("n", "<leader>fsb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { noremap = true, silent = true })
          # map("n", "<leader>fj", "<cmd>Telescope jumplist<cr>", { noremap = true, silent = true })
          # map("n", "<leader>ft", "<cmd>Telescope treesitter<cr>", { noremap = true, silent = true })
          # map("n", "<leader>fgbb", "<cmd>Telescope git_branches<cr>", { noremap = true, silent = true })
          # map("n", "<leader>fgc", "<cmd>Telescope git_commits<cr>", { noremap = true, silent = true })
          # map("n", "<leader>fgbc", "<cmd>Telescope git_bcommits<cr>", { noremap = true, silent = true })
          # map("n", "<leader>fgs", "<cmd>Telescope git_status<cr>", { noremap = true, silent = true })
          # map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { noremap = true, silent = true })
          # map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { noremap = true, silent = true })
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
        #folding = true;
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
        ];
      };
      treesitter-context.enable = true;
      notify.enable = true;
      tmux-navigator.enable = true;
      mini = {
        enable = true;
        modules = {
          ai = { n_lines = 500; };
          surround = { };
          trailspace = { };
          # notify= { };
          comment = { };
          statusline = { };
          basics = {
            options.extra_ui = true;
            mappings.windows = true;
          };
          # indentscope={ };
        };
      };

      # fugitive.enable = true;
      # noice.enable = true;
      # notify.enable = true;
      # cmp = {
      #   enable = true;
      #   settings = {
      #     mapping = {
      #       "<CR>" = "cmp.mapping.confirm({ select = true })";
      #       "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
      #     };
      #     snippet.expand = "luasnip";
      #     sources = [
      #       { name = "buffer"; }
      #       { name = "luasnip"; }
      #       { name = "nvim_lsp"; }
      #       { name = "path"; }
      #       { name = "tmux"; }
      #     ];
      #   };
      # };
      # lualine = {
      #   enable = true;
      #   theme = "base16";
      #   iconsEnabled = false;
      #   sections = {
      #     lualine_a = [ "" ];
      #     lualine_b = [ "" ];
      #     lualine_c = [ "location" { name = "filename"; extraConfig.path = 1; } "filetype" ];
      #     lualine_x = [ "diagonostics" ];
      #     lualine_y = [ "" ];
      #     lualine_z = [ "mode" ];
      #   };
      #   componentSeparators = {
      #     left = "";
      #     right = "";
      #   };
      #   sectionSeparators = {
      #     left = "";
      #     right = "";
      #   };
      # };
    };
    # extraPlugins = with pkgs.vimPlugins; [
    #   editorconfig-vim
    #   # himalaya-vim
    # ];
  };
}
