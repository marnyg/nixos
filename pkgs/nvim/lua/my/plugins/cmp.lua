local cmp = require("cmp")
local lspkind = require('lspkind')

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
cmp.setup({
    preselect = cmp.PreselectMode.None,

    --completion = {
    --	completeopt = "menu,menuone,noselect",
    --},
    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol_text',  -- show only symbol annotations
            preset = 'codicons',
            maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
            menu = ({
                nvim_lsp = "[LSP]",
                nvim_lsp_document_symbol = "[LSP_doc]",
                nvim_lsp_signature_help = "[LSP_sign]",
                buffer = "[Buffer]",
                luasnip = "[LuaSnip]",
                nvim_lua = "[Lua]",
                omni = "[Omni]",
                calc = "[Calc]",
                neorg = "[Neorg]",
                path = "[Path]",
            })

            -- The function below will be called before any actual modifications from lspkind
            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            --before = function(entry, vim_item)
            --    return vim_item
            --end
        })
    },

    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },

    mapping = {
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-e>'] = cmp.mapping.abort(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-c>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm(),
    },

    experimental = {
        ghost_text = true,
    },

    sources = {
        { name = "neorg",                    priority = 1 },
        { name = "nvim_lsp",                 priority = 1 },
        { name = 'nvim_lsp_document_symbol', priority = 2 },
        { name = 'nvim_lsp_signature_help',  priority = 2 },
        { name = "luasnip",                  priority = 3 },
        { name = "nvim_lua",                 priority = 4 },
        { name = "calc",                     priority = 4 },
        { name = "path",                     priority = 4 },
        { name = "buffer",                   priority = 4 },
        { name = 'omni',                     priority = 4 }
    },
})

cmp.setup.cmdline(":", {
    sources = {
        { name = "cmdline" },
        { name = "path" },
    },
})

--cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())

--[[ local neorg = require('neorg')
            local function load_completion()
                neorg.modules.load_module("core.norg.completion", nil, {
                    engine = "nvim-cmp"
                })
            end
            if neorg.is_loaded() then
                load_completion()
            else
                neorg.callbacks.on_event("core.started", load_completion)
            end
            ]]
