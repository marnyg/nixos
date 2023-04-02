{ pkgs }:
let
  config-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "config-nvim";
    src = ../.;
  };
  lsp-servers = with pkgs; [ lazygit sumneko-lua-language-server cargo rust-analyzer rnix-lsp rustc manix ripgrep ];
in
pkgs.neovim.override {

  configure = {
    withNodeJs = false;
    withPython3 = false;

    customRC = ''
      " Update the PATH to include cargo, manix, and ripgrep
      let $PATH = $PATH . ':' . '${pkgs.lib.makeBinPath lsp-servers }'

      let g:disable_paq = v:true
      luafile ${config-nvim}/init.lua
      luafile ${config-nvim}/lua/my/options/init.lua
      luafile ${config-nvim}/lua/my/keybinds/init.lua
      luafile ${config-nvim}/lua/my/keybinds/UI.lua
    '';
    packages.myVimPackage = with pkgs.vimPlugins;  {
      # see examples below how to use custom packages
      start = [
        nvim-lspconfig

        #nvim-treesitter.withAllGrammars
        #(nvim-treesitter.withPlugins (
        #    plugins: with plugins; [
        #      #nix
        #      python
        #    ]
        #  ))
        # Colorscheme {{{1k
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

        # mystuff {{{1
        {
          plugin = neorg;
          config = "luafile ${config-nvim}/lua/my/plugins/neorg.lua";
        }
        {
          plugin = nvim-tree-lua;
          config = "lua require('nvim-tree').setup({})";
        }
        {
          plugin = nvim-cmp;
          config = "luafile ${config-nvim}/lua/my/plugins/cmp.lua";
        }
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

            local Terminal  = require('toggleterm.terminal').Terminal
            local lazygit = Terminal:new({ 
            direction = "float",
            float_opts = {
              border = "double",
            },
            cmd = "lazygit", 
            hidden = true 
            })

            function _lazygit_toggle()
              lazygit:toggle()
            end
            
            vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true})
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


        # LSP {{{1
        {
          plugin = nvim-lspconfig;
          #    config = builtins.readFile ./fnl/config/alpha.fnl;
          config = "luafile ${config-nvim}/lua/my/keybinds/lsp.lua";
          #type = "lua";
          #type = "fennel";
        }

        #vimExtraPlugins.lspactions
        {
          plugin = lspkind-nvim;
        }
        #vimExtraPlugins.null-ls-nvim




        # Syntax {{{1
        {
          #plugin = (nvim-treesitter.withPlugins (_: tree-sitter.allGrammars));
          plugin = nvim-treesitter.withAllGrammars;
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
