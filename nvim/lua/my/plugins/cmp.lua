local cmp = require("cmp")

cmp.setup({
	preselect = cmp.PreselectMode.None,

	completion = {
		completeopt = "menu,menuone,noselect",
	},

	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},

	mapping = {
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
		{ name = "neorg" },
		{ name = "luasnip" },
		{ name = "nvim_lua" },
		{ name = "nvim_lsp" },
		{ name = "calc" },
		{ name = "path" },
		{ name = "buffer" },
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
