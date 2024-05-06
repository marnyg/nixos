{ config, pkgs, ... }: {
  options = { };

  imports = [ ./golang.nix ./ocaml.nix ./lsp.nix ./treesitter.nix ./cmp.nix ./terraform.nix ];

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
        desc = "Enable spell checking and set textwidth to 101 when entering a neorg file";
        pattern = [ "*.norg" ];
        command = ''
          	set spell
          	set tw=101
          	'';
      }
      {
        event = [ "BufLeave" "BufWinLeave" ];
        desc = "Disable spell checking and set textwidth to 0 when leaving a neorg file";
        pattern = [ "*.norg" ];
        command = ''
          	set nospell
          	set tw=0
          	'';
      }
      {
        event = [ "BufReadPost" ];
        pattern = [ "*" ];
        desc = "Set the cursor to previous position when opening a file";
        callback = {
          __raw = ''
            function()
              local last_pos = vim.fn.line("'\"")
              if last_pos > 0 and last_pos <= vim.fn.line("$") then
                vim.api.nvim_win_set_cursor(0, {last_pos, 0})
              end
            end
          '';
        };
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
      vim.lsp.inlay_hint.enable(false)
    '';

    extraPackages = with pkgs; [
      fd
      gcc
      nixpkgs-fmt
      ripgrep
      shellcheck
    ];

    # langs.ocaml.enable = true;
    # langs.golang.enable = true;
    langs.terraform.enable = true;

    plugins = {
      lsp.enable = true;

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
          "<leader>s," = { action = "oldfiles"; options.desc = "[S]earch Recent Files (\",\" for repeat)"; };
          "<leader><leader>" = { action = "buffers"; options.desc = "[ ] Find existing buffers"; };
        };
        # extraOptionst='' '';
      };

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
          "core.defaults" = { __empty = null; };
          "core.ui".__empty = null;
          # these need nvim v10
          "core.tempus".__empty = null;
          "core.ui.calendar".__empty = null;
          # these need nvim v10
          "core.summary" = { __empty = null; };
          "core.concealer".config.icon_preset = "diamond";
          "core.dirman".config.workspaces.notes = "~/git/notes";
          "core.dirman".config.workspaces.default = "~/git/notes";
          "core.keybinds".config.default_keybinds = true;
          "core.completion".config = { engine = "nvim-cmp"; };
          "core.integrations.telescope" = { __empty = null; };
          "core.integrations.treesitter" = { __empty = null; };
        };
      };


      luasnip = {
        enable = true;
        extraConfig.enable_autosnippets = true;
      };
    };
    extraPlugins = with pkgs.vimPlugins; [
      lazygit-nvim # TODO: add keybindings for opening lazygit
      vim-dadbod
      neorg-telescope
      virtual-types-nvim
      vim-dadbod-ui # TODO: add keybindings for opening dbui
      # TODO: add https://github.com/chrisgrieser/nvim-various-textobjs
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
