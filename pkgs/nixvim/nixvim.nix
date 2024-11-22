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
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
    };
    autoCmd = [
      {
        event = [ "BufEnter" "BufWinEnter" ];
        desc = "Enable spell checking and set textwidth to 101 when entering a neorg file";
        pattern = [ "*.norg" ];
        command = ''
          set spell
          set tw=100
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

    extraConfigLua = /*lua*/''
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
      map("n", "<leader>x", "<cmd>.lua<CR>", { desc = "Execute the current line" })
      map("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })
      map("n", "<leader>fs", function() require("telescope.builtin").spell_suggest(require("telescope.themes").get_dropdown{}) end, { desc = 'Open [F]ixes for [S]pelling' })

      local neorg_callbacks = require("neorg.core.callbacks")

      neorg_callbacks.on_event("core.keybinds.events.enable_keybinds", function(_, keybinds)
          -- Map all the below keybinds only when the "norg" mode is active
          keybinds.map_event_to_mode("norg", {
              n = { -- Bind keys in normal mode
                  { "<leader>nf", "core.integrations.telescope.find_linkable" },
                  { "<leader>ni", "core.integrations.telescope.insert_link" },
              },

              i = { -- Bind in insert mode
                  { "<M-i>", "core.integrations.telescope.insert_link" },
              },
          }, {
              silent = true,
              noremap = true,
          })
      end)
      do
          local _, neorg = pcall(require, "neorg.core")
          local dirman = neorg.modules.get_module("core.dirman")
          local function get_todos(dir, states)
              local current_workspace = dirman.get_current_workspace()
              local dir = current_workspace[2]:tostring()
              require('telescope.builtin').live_grep{ cwd = dir }
              vim.fn.feedkeys('^ *([*]+|[-]+) +[(]' .. states .. '[)]')
          end

          -- This can be bound to a key
          vim.keymap.set('n', '<leader>nt', function() get_todos('~/notes', '[^x_]') end)
      end

      vim.notify = require('mini.notify').make_notify()
      vim.lsp.inlay_hint.enable(false)
    '';

    extraPackages = with pkgs; [
      fd
      gcc
      nixpkgs-fmt
      ripgrep
      fzf
      shellcheck
      #ollama
    ];

    # langs.ocaml.enable = true;
    # langs.golang.enable = true;
    # langs.terraform.enable = true;

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
        filetypes = {
          markdown = true;
          cvs = false;
          gitcommit = true;
          gitrebase = true;
          help = false;
          hgcommit = true;
          svn = false;
          yaml = true;
        };
      };
      markdown-preview = {
        enable = true;
      };

      friendly-snippets.enable = true;
      image.enable = false;

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
      web-devicons.enable = true;
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
      none-ls = {
        enable = true;
        enableLspFormat = true;

        sources = {
          hover.dictionary.enable = true;
          hover.dictionary.settings = ''{filetypes = { "org", "text", "markdown", "norg"}}'';

          code_actions.proselint.enable = true;
          code_actions.proselint.settings = ''{filetypes = { "org", "text", "markdown", "norg"}}'';
          code_actions.gitsigns.enable = true;

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
          # "core.concealer".config.icon_preset = "varied";
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
        settings.enable_autosnippets = true;
      };
      avante = {
        enable = true;
      };
      # ollama = {
      #   enable = true;
      #   model = "llama3:8b";
      #   prompts.Sample_Prompt = {
      #     prompt = "This is a sample prompt that receives $input and $sel(ection), among others.";
      #     inputLabel = "> ";
      #     model = "llama3:8b";
      #     action = "display";
      #   };
      # };
    };
    extraPlugins = with pkgs.vimPlugins; [
      lazygit-nvim # TODO: add keybindings for opening lazygit
      vim-dadbod
      neorg-telescope
      virtual-types-nvim

      #installing parrot.nvim from https://github.com/frankroeder/parrot.nvim?tab=readme-ov-file#roadmap
      #{
      #  plugin = (pkgs.fetchFromGitHub
      #    {
      #      owner = "frankroeder";
      #      repo = "parrot.nvim";
      #      rev = "976c37462436ada5ea2239430a1e5bb2ce52944a";
      #      sha256 = "sha256-AF7nM/sWONhS7vDwbvOxEYHSwrRndaC1GvS5MlXBIts=";
      #    });
      #  config = /*lua*/''
      #    lua <<EOF
      #      require("parrot").setup {
      #        providers = {
      #          anthropic = {
      #            api_key = os.getenv "ANTHROPIC_API_KEY",

      #        },
      #        -- Default target for  PrtChatToggle, PrtChatNew, PrtContext and the chats opened from the ChatFinder
      #        -- values: popup / split / vsplit / tabnew
      #        toggle_target = "popup",
      #      }

      #      --keymaps
      #      vim.g.mapleader = ' '
      #      vim.g.maplocalleader = ' '
      #      vim.api.nvim_set_keymap('n', '<leader>ac', '<cmd>PrtChatToggle<CR>', { noremap = true, silent = true })
      #      vim.api.nvim_set_keymap('v', '<leader>ac', ":PrtChatPaste<CR>", { noremap = true, silent = true })
      #      vim.api.nvim_set_keymap('n', '<leader>an', '<cmd>PrtChatNew popup<CR>', { noremap = true, silent = true })
      #      vim.api.nvim_set_keymap('n', '<leader>af', '<cmd>PrtChatFinder<CR>', { noremap = true, silent = true })
      #      vim.api.nvim_set_keymap('v', '<leader>ar', ":'<,'>PrtRewrite<CR>", { noremap = true, silent = true })
      #      vim.api.nvim_set_keymap('v', '<leader>aa', ":'<,'>PrtAppend<CR>", { noremap = true, silent = true })
      #      vim.api.nvim_set_keymap('v', '<leader>ap', ":'<,'>PrtPrepend<CR>", { noremap = true, silent = true })
      #    EOF
      #  '';

      #}

      vim-dadbod-ui # TODO: add keybindings for opening dbui
      # TODO: add https://github.com/chrisgrieser/nvim-various-textobjs
      {
        plugin = boole-nvim;
        config = /*lua*/'' 
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
