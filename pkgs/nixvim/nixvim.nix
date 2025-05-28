{ pkgs, ... }: {
  options = { };

  imports = [ ./langs ./lsp.nix ./treesitter.nix ./cmp.nix ];

  config = {
    opts = {
      relativenumber = true; # Show relative line numbers
      updatetime = 250;
      timeoutlen = 300;
      foldlevel = 20;
      foldmethod = "expr";
      conceallevel = 2;
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
    };
    autoCmd = [
      {
        event = [ "FileType" ];
        desc = "Set up vim-dadbod-completion for SQL files";
        pattern = [ "sql" "mysql" "plsql" ];
        callback = {
          __raw = ''
            function()
              require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })
            end
          '';
        };
      }
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
    diagnostic.settings.virtual_text = true;

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
      map("v", "<leader>x", ":'<,'>lua<CR>", { desc = "Execute selected Lua code" })
      map("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })

    '';

    extraPackages = with pkgs; [
      fd
      gcc
      nixpkgs-fmt
      ripgrep
      fzf
      shellcheck
      #ollama
      ty
    ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
      pngpaste
    ];

    langs.ocaml.enable = true;
    langs.python.enable = true;
    langs.golang.enable = true;
    langs.rust.enable = true;
    langs.terraform.enable = true;
    langs.gleam.enable = true;

    lsp.servers.ty = {
      enable = true;
      settings = {
        cmd = [
          "ty"
          "server"
        ];
        filetypes = [
          "python"
        ];
        rootMarkers = [ "pyproject.toml" "uv.lock" ".git" ];
      };
    };

    plugins = {
      lsp.enable = true;
      lsp.servers.jsonls.enable = true;
      lsp.servers.html.enable = true;
      lsp.servers.postgres_lsp.enable = true;
      lsp.servers.leanls.enable = true;

      #lsp.inlayHints.enable = true;

      # copilot-cmp = {
      #   enable = true;
      # };
      # copilot-lua = {
      #   enable = true;
      #   suggestion.enabled = false;
      #   panel.enabled = false;
      #   filetypes = {
      #     markdown = true;
      #     cvs = false;
      #     gitcommit = true;
      #     gitrebase = true;
      #     help = false;
      #     hgcommit = true;
      #     svn = false;
      #     yaml = true;
      #   };
      # };
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
        luaConfig.post = ''
          vim.keymap.set("n", "<leader>fs", function() require("telescope.builtin").spell_suggest(require("telescope.themes").get_dropdown{}) end, { desc = 'Open [F]ixes for [S]pelling' })
        '';
      };

      fidget.enable = true;

      harpoon = {
        enable = true;
        enableTelescope = true;
        luaConfig.post = ''
          vim.keymap.set('n', '<leader>a', '<cmd>lua require"harpoon":list():add()<cr>')
          vim.keymap.set('n', '<leader>h', '<cmd>lua require"harpoon".ui:toggle_quick_menu(require"harpoon":list())<cr>')
          vim.keymap.set('n', '<leader>j', '<cmd>lua require"harpoon":list():select(1)<cr>')
          vim.keymap.set('n', '<leader>k', '<cmd>lua require"harpoon":list():select(2)<cr>')
          vim.keymap.set('n', '<leader>l', '<cmd>lua require"harpoon":list():select(3)<cr>')
          vim.keymap.set('n', '<leader>;', '<cmd>lua require"harpoon":list():select(4)<cr>')
        '';
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
        luaConfig.post = /*lua*/''
          vim.notify = require('mini.notify').make_notify()
        '';
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

          formatting.treefmt.enable = true;
          formatting.treefmt.package = null;
          formatting.treefmt.settings = {
            filetypes = { }; # All filetypes
            formatStdin = true; # Read from formated file from stdin
            condition.__raw = "function() return true end";
          };
        };
      };

      neorg = {
        enable = true;
        telescopeIntegration.enable = true;
        settings.load = {
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
        luaConfig.post = /*lua*/''
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
              loirman = neorg.modules.get_module("core.dirman")
              local function get_todos(dir, states)
                  local current_workspace = dirman.get_current_workspace()
                  local dir = current_workspace[2]:tostring()
                  require('telescope.builtin').live_grep{ cwd = dir }
                  vim.fn.feedkeys('^ *([*]+|[-]+) +[(]' .. states .. '[)]')
              end

              -- This can be bound to a key
              vim.keymap.set('n', '<leader>nt', function() get_todos('~/sync/notes', '[^x_]') end)
          end
        '';
      };

      luasnip = {
        enable = true;
        settings.enable_autosnippets = true;
      };

      octo.enable = true;
      supermaven.enable = true;
      iron = {
        enable = true;
        # lazyLoad.settings.colorscheme = "catppuccin-mocha";
        settings = {
          scratch_repl = true;

          repl_definition = {
            sh = {
              command = [ "zsh" ];
            };
            python = {
              command = [ "python3" ];
              format = {
                __raw = ''
                  require("iron.fts.common").bracketed_paste_python
                '';
              };
            };
            nix = {
              command = [ "nix" "repl" "--expr" "import <nixpkgs>{}" ];
            };
            ocaml = {
              command = [ "utop" ];
              format = {
                __raw = ''
                  function(lines)
                    table.insert(lines, ";;\13")
                    return lines
                  end
                '';
              };
            };
          };
          repl_open_cmd = "vertical botright 80 split";

          keymaps = {
            send_motion = "<space>sc";
            visual_send = "<space>sc";
            send_file = "<space>ff";
            send_line = "<space>sl";
            send_paragraph = "<space>sp";
            send_until_cursor = "<space>su";
            send_mark = "<space>sm";
            mark_motion = "<space>mc";
            mark_visual = "<space>mc";
            remove_mark = "<space>md";
            cr = "<space>s<cr>";
            interrupt = "<space>s<space>";
            exit = "<space>sq";
            clear = "<space>cl";
          };

          highlight = {
            italic = true;
          };
          ignore_blank_lines = true;
        };
        luaConfig.post = ''
          vim.keymap.set('n', '<space>rs', '<cmd>IronRepl<cr>')
          vim.keymap.set('n', '<space>rr', '<cmd>IronRestart<cr>')
          vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')
          vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>')
        '';
      };

      vim-dadbod = {
        enable = true;
      };
      vim-dadbod-completion = {
        enable = true;
      };
      vim-dadbod-ui = {
        enable = true;
        ##luaConfig.post = ''
        #    vim.keymap.set('n', '<leader>db', '<cmd>DBUIToggle<cr>')
        #  '';
      };
      clipboard-image = {
        enable = true;
      };
      lazygit = {
        #lazygit-nvim # TODO: add keybindings for opening lazygit
        enable = true;
      };
      avante = {
        enable = true;
        #  settings = {
        #    mode = "agentic";
        #    provider = "openai";
        #    openai = {
        #      endpoint = "https://openrouter.ai/api/v1";
        #      model = "google/gemini-2.5-pro-preview";
        #    };
        #  };

        luaConfig.post = /*lua*/''
          require("avante").setup({
            model = "agentic",
            provider = "openai",
            openai = {
              endpoint = "https://openrouter.ai/api/v1",
              model = "google/gemini-2.5-pro-preview",
            },
            -- system_prompt as function ensures LLM always has latest MCP server state
            -- This is evaluated for every message, even in existing chats
            system_prompt = function()
              local hub = require("mcphub").get_hub_instance()
              return hub and hub:get_active_servers_prompt() or ""
            end,
            -- Using function prevents requiring mcphub before it's loaded
            custom_tools = function()
              return {
                require("mcphub.extensions.avante").mcp_tool(),
              }
            end,

          })
          vim.keymap.set('n', '<leader>an', '<cmd>AvanteChatNew<cr>')
          vim.keymap.set('n', '<leader>ah', '<cmd>AvanteHistory<cr>')

        '';

      };

    };
    extraPlugins = with pkgs.vimPlugins; [
      img-clip-nvim

      {
        plugin = pkgs.mcphub-nvim; # Added via overlay
        config = /*lua*/''
          lua <<EOF
            require("mcphub").setup({
              cmd = "${pkgs.mcphub}/bin/mcp-hub",
              extensions = {
                avante = {
                    make_slash_commands = true, -- make /slash commands from MCP server prompts
                }
              }
            })
          EOF
        '';
      }
      (
        pkgs.vimUtils.buildVimPlugin {
          name = "carp-vim";
          src = pkgs.fetchFromGitHub {
            owner = "hellerve";
            repo = "carp-vim";
            rev = "d595753eacb167fbe42939f0cbee37d74e8a53e8";
            hash = "sha256-1QW9HpB7ERz+6trsSKyA6+dZqeHOW1eHOpgcpVX7PO4=";
          };
        }
      )


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
