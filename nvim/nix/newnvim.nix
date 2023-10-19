{ pkgs }:
let
  config-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "config-nvim";
    src = ../.;
  };
  #lsp-servers = with pkgs; [ sumneko-lua-language-server cargo rust-analyzer rnix-lsp rustc manix ripgrep ];
  cs-snippets = pkgs.fetchFromGitHub
    {
      owner = "honza";
      repo = "vim-snippets";
      rev = "master";
      sha256 = "9YLkTpEhTLFpAnikEaYasu1/dMqOn/uc3L78wgVdYqY=";
    } + "/snippets/cs.snippets";
in
pkgs.neovim.override {

  configure = {

    withNodeJs = false;
    withPython3 = false;

    customRC = ''
      " Update the PATH to include cargo, manix, and ripgrep

      let g:disable_paq = v:true
      luafile ${config-nvim}/lua/my/options/init.lua
      luafile ${config-nvim}/lua/my/keybinds/init.lua
      luafile ${config-nvim}/lua/my/keybinds/UI.lua
      source ${config-nvim}/lua/my/ft/hcl/ft.detect
      source ${config-nvim}/lua/my/ft/hcl/syntax.vim
      lua <<EOF
        local map = vim.keymap.set
        map("", "Q", "", {}) -- Begone, foul beast. I can invoke your wrath with gQ anyway.
        map("", "<C-z>", "", {}) 
        map("", "<leader>w", ":w<CR>", {})
      EOF
    '';
    packages.myVimPackage = with pkgs.vimPlugins;  {
      # see examples below how to use custom packages
      start = [
        {
          plugin = plenary-nvim;
          #config = "lua vim.g.mapleader = ' '"; #hack need to set leader before binding keys
        }
        {
          plugin = catppuccin-nvim;
          config = "colorscheme catppuccin";
        }
        {
          plugin = nvcode-color-schemes-vim;
        }
        {
          plugin = copilot-lua;
          config = ''
            lua <<EOF
            vim.g.copilot_proxy_strict_ssl = false

            require('copilot').setup({ 
              copilot_node_command = '${pkgs.nodejs_20}/bin/node',
              suggestion = {
                keymap= {
                  accept = "<M-p>"
                }
              }
            })
            EOF
          '';
        }


        # mystuff {{{1
        {
          plugin = neorg;
          config = "luafile ${config-nvim}/lua/my/plugins/neorg.lua";
        }

        {
          plugin = comment-nvim;
          config = "lua require('Comment').setup() ";
        }
        {
          plugin = pkgs.vimExtraPlugins.nui-nvim;
          config = "lua require('nui').setup({})";
          #config = "lua require('nui').setup({})";


        }
        {
          plugin = pkgs.vimExtraPlugins.neo-tree-nvim;
          config = ''
            lua <<EOF
            vim.keymap.set("n", "<C-n>", ":Neotree float toggle reveal<CR>")
            vim.keymap.set("n", "<C-g>", ":Neotree git_status float toggle <CR>")
            require("neo-tree").setup({
              default_component_configs  = {
                popup_border_style = "rounded",
                enable_git_status = true,
                enable_diagnostics = true,
                container = {
                  enable_character_fade = true
                },
                mappings = {
                  ["U"] = function(state)
                    local node = state.tree:get_node()
                    require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
                  end,
                  ["esc"] = "close_window",
                  ['D'] = "diff_files"
                }
              }
            })
            diff_files = function(state)
            local node = state.tree:get_node()
            local log = require("neo-tree.log")
            state.clipboard = state.clipboard or {}
            if diff_Node and diff_Node ~= tostring(node.id) then
              local current_Diff = node.id
              require("neo-tree.utils").open_file(state, diff_Node, open)
              vim.cmd("vert diffs " .. current_Diff)
              log.info("Diffing " .. diff_Name .. " against " .. node.name)
              diff_Node = nil
              current_Diff = nil
              state.clipboard = {}
              require("neo-tree.ui.renderer").redraw(state)
            else
              local existing = state.clipboard[node.id]
              if existing and existing.action == "diff" then
                state.clipboard[node.id] = nil
                diff_Node = nil
                require("neo-tree.ui.renderer").redraw(state)
              else
                state.clipboard[node.id] = { action = "diff", node = node }
                diff_Name = state.clipboard[node.id].node.name
                diff_Node = tostring(state.clipboard[node.id].node.id)
                log.info("Diff source file " .. diff_Name)
                require("neo-tree.ui.renderer").redraw(state)
              end
            end
          end

          EOF
          '';
        }


        #
        #cmp stuff
        #
        lspkind-nvim
        {
          plugin = nvim-cmp;
          config = "luafile ${config-nvim}/lua/my/plugins/cmp.lua";
        }
        cmp-nvim-lsp
        cmp-nvim-lsp-signature-help
        cmp-nvim-lsp-document-symbol
        {
          plugin = cmp_luasnip;
          # config = ''
          #   lua <<EOF
          #   require("luasnip.loaders.from_snipmate").lazy_load({paths = "${}"});
          #   EOF
          # '';
          config = ''
            lua <<EOF
            local ls = require("luasnip")
            local path_to_cs_snippets = [[${cs-snippets}]]  -- use double square brackets for multi-line string in Lua
            -- print("Path to CS snippets: " .. path_to_cs_snippets)
            require("luasnip.loaders.from_snipmate").load({ paths = {"~/../../${cs-snippets}"} });
            EOF
          '';
        }
        cmp-calc
        cmp-buffer
        cmp-omni
        cmp-path

        #
        #
        #

        {
          plugin = diffview-nvim;
          #config = "lua require('diffview.nvim')";
        }
        #vimExtraPlugins.lsp-rooter
        {
          plugin = project-nvim;
          config = "lua require('project_nvim').setup({})";
        }
        {
          plugin = neodev-nvim;
          config = "lua require('neodev').setup({})";
        }
        {
          plugin = which-key-nvim;
          config = "lua require('which-key').setup({})";
        }
        {
          plugin = fidget-nvim;
          config = "lua require('fidget').setup({})";
        }
        {
          plugin = luasnip;
        }


        #
        #cmp stuff
        #
        lspkind-nvim
        {
          plugin = nvim-cmp;
          config = "luafile ${config-nvim}/lua/my/plugins/cmp.lua";
        }
        cmp-nvim-lsp
        cmp-nvim-lsp-signature-help
        cmp-nvim-lsp-document-symbol
        cmp_luasnip
        cmp-calc
        cmp-buffer
        cmp-omni
        cmp-path

        #
        #
        #

        {
          plugin = diffview-nvim;
          #config = "lua require('diffview.nvim')";
        }
        #vimExtraPlugins.lsp-rooter
        {
          plugin = project-nvim;
          config = "lua require('project_nvim').setup({})";
        }
        {
          plugin = neodev-nvim;
          config = "lua require('neodev').setup({})";
        }
        {
          plugin = which-key-nvim;
          config = "lua require('which-key').setup({})";
        }
        {
          plugin = fidget-nvim;
          config = "lua require('fidget').setup({})";
        }
        {
          plugin = luasnip;
        }
        {
          plugin = nvim-notify;
          config = "lua require('notify').setup({})";
        }
        {
          plugin = tabby-nvim;
          config = "lua require('tabby').setup({ tabline = require('tabby.presets').active_wins_at_tail })";
        }
        {
          plugin = harpoon;
          config = ''
            lua <<EOF
            local mark = require("harpoon.mark")
            local ui = require("harpoon.ui")
            
            vim.keymap.set("n", "<leader>a", mark.add_file)
            vim.keymap.set("n", "<leader>h", ui.toggle_quick_menu)
            
            vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end)
            vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end)
            vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end)
            vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end)
            EOF
          '';
        }
        {
          plugin = gitsigns-nvim;
          config = ''
            lua <<EOF
              require('gitsigns').setup({
              current_line_blame = true,
              })
            EOF
          '';
        }
        {
          plugin = tmuxNavigator;
          config = ''
            lua <<EOF
            vim.keymap.set("n", "<C-h>", ":<C-U>TmuxNavigateLeft<cr>")
            vim.keymap.set("n", "<C-j>", ":<C-U>TmuxNavigateDown<cr>")
            vim.keymap.set("n", "<C-k>", ":<C-U>TmuxNavigateUp<cr>")
            vim.keymap.set("n", "<C-;>", ":<C-U>TmuxNavigateRight<cr>")
            EOF
          '';
        }
        #vimExtraPlugins.dirbuf-nvim


        {
          plugin = toggleterm-nvim;
          config = ''
            lua <<EOF
            require('toggleterm').setup {
              open_mapping = [[<leader>tt]],
            }
            local opts = {buffer = 0}
            vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
            vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
            vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
            vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
            vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)

            --local Terminal  = require('toggleterm.terminal').Terminal
            --local lazygit = Terminal:new({ 
            --direction = "float",
            --float_opts = {
            --  border = "double",
            --},
            --cmd = "lazygit", 
            --hidden = true 
            --})

            --function _lazygit_toggle()
            --  lazygit:toggle()
            --end
            --
            --vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true})
            EOF
          '';
        }
        {
          plugin = neogit;
          config = "lua require('neogit').setup { integrations = { diffview = true }}";
        }
        #{
        #  plugin = lazygit-nvim;
        #  #config = "require('telescope').load_extension('lazygit')";
        #}
        {
          plugin = pkgs.vimExtraPlugins.git-conflict-nvim;
          config = "lua require('git-conflict').setup({})";
        }


        # LSP {{{1
        {
          plugin = nvim-lspconfig;
          #    config = builtins.readFile ./fnl/config/alpha.fnl;
          config = "luafile ${config-nvim}/lua/my/keybinds/lsp.lua";
          #type = "lua";
          #type = "fennel";
        }

        #vimExtraPlugins.lspactions
        #vimExtraPlugins.null-ls-nvim




        # Syntax {{{1
        {
          plugin = (nvim-treesitter.withPlugins (plugins: with plugins; [ norg hcl nix python rust c_sharp go lua json markdown css javascript typescript zig dhall vue ]));
          config = "luafile ${config-nvim}/lua/my/plugins/treesitter.lua";
        }
        {
          plugin = nvim-treesitter-textobjects;
        }
        {
          plugin = nvim-surround;
          config = "lua require('nvim-surround').setup({})";
        }
        {
          plugin = pkgs.vimExtraPlugins2.boole;
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
        {
          plugin = pkgs.vimExtraPlugins.iron-nvim;
          config = '' 
            lua <<EOF
            local iron = require("iron.core")
            
            iron.setup {
              config = {
                -- Whether a repl should be discarded or not
                scratch_repl = true,
                -- Your repl definitions come here
                repl_definition = {
                  sh = {
                    -- Can be a table or a function that
                    -- returns a table (see below)
                    command = {"bash"}
                  },
                  nix = {
                    -- Can be a table or a function that
                    -- returns a table (see below)
                    command = {"nix", "repl"}
                  }
                },
                -- How the repl window will be displayed
                -- See below for more information
                repl_open_cmd = require('iron.view').bottom(40),
              },
              -- Iron doesn't set keymaps by default anymore.
              -- You can set them here or manually add keymaps to the functions in iron.core
              keymaps = {
                send_motion = "<space>sc",
                visual_send = "<space>sc",
                send_file = "<space>sf",
                send_line = "<space>sl",
                send_mark = "<space>sm",
                mark_motion = "<space>mc",
                mark_visual = "<space>mc",
                remove_mark = "<space>md",
                cr = "<space>s<cr>",
                interrupt = "<space>s<space>",
                exit = "<space>sq",
                clear = "<space>cl",
              },
              -- If the highlight is on, you can change how it looks
              -- For the available options, check nvim_set_hl
              highlight = {
                italic = true
              },
              ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
            }
            
            -- iron also has a list of commands, see :h iron-commands for all available commands
            vim.keymap.set('n', '<space>rs', '<cmd>IronRepl<cr>')
            vim.keymap.set('n', '<space>rr', '<cmd>IronRestart<cr>')
            vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>')
            vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')
        EOF
        '';
        }



        # Terminal integration {{{1
        #vimExtraPlugins.smart-term-esc-nvim
        #vimExtraPlugins.iron-nvim

        #

        ## Marks {{{1k
        #vimExtraPlugins.marks-nvim

        # Fuzzy finder {{{1k
        {
          plugin = telescope-nvim;
          config = "luafile ${config-nvim}/lua/my/plugins/telescope.lua";
        }
        {
          plugin = telescope-symbols-nvim;
        }
        {
          plugin = telescope-fzf-native-nvim;
        }
        #vimExtraPlugins.telescope-heading-nvim



        # Icon {{{1k
        {
          plugin = nvim-web-devicons;
        }

        ## Statusline {{{1k
        #vimExtraPlugins.feline-nvim

        ## Cursorline {{{1k
        #vimPlugins.nvim-cursorline

        ## Git {{{1k
        #vimPlugins.gitsigns-nvim

        ## Comment {{{1k
        #vimPlugins.kommentary

        ## Quickfix {{{1k
        #vimExtraPlugins.nvim-pqf

        ## Motion {{{1k
        #vimPlugins.vim-wordmotion
        #vimPlugins.lightspeed-nvim

        ## Search {{{1k
        #vimPlugins.vim-visualstar

        ## Editing support {{{1k
        #vimExtraPlugins.bullets-vim
        #vimPlugins.vim-repeat
        #vimPlugins.vim-unimpaired
        #vimPlugins.numb-nvim
        #vimExtraPlugins.dial-nvim
        #vimExtraPlugins.nvim-lastplace

        ## Command line {{{1k
        #vimPlugins.vim-rsi

        ## Language specific {{{1

        ### Markdown / LaTeX {{{2k
        #vimExtraPlugins.glow-nvim
        #vimExtraPlugins.vim-gfm-syntax
        #vimPlugins.vim-pandoc-syntax
        #vimPlugins.vim-table-mode
        #vimExtraPlugins.telescope-bibtex-nvim

        ## Nix {{{2k
        #        vimPlugins.vim-nix

        ### Bash {{{2k
        #vimExtraPlugins.bats-vim

        ### Lua {{{2k
        #vimPlugins.BetterLua-vim

        ### Fennel {{{2k
        #vimExtraPlugins.vim-fennel-syntax

        ### Python {{{2
        #vimExtraPlugins.requirements-txt-vim

        # }}}1
      ];
      #opt = [ pkgs.rnix-lsp ];
    };
  };
}
