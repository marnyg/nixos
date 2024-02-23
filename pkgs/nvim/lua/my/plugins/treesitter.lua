local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()

--parser_configs.norg = {
--    install_info = {
--        url = "/home/vhyrro/dev/tree-sitter-norg",
--        files = { "src/parser.c", "src/scanner.cc" },
--        branch = "main",
--    },
--}

--parser_configs.norg_meta = {
--    install_info = {
--        url = "/home/vhyrro/dev/tree-sitter-norg-meta",
--        files = { "src/parser.c" },
--    }
--}

require("nvim-treesitter.configs").setup({

	highlight = {
		enable = true,
	},

	incremental_selection = {
		enable = true,

		keymaps = {
			init_selection = "gnn",
			node_incremental = "gnn",
			scope_incremental = "gns",
			node_decremental = "gnp",
		},
	},

	indent = {
		enable = true,
	},

	query_linter = {
		enable = true,
		use_virtual_text = true,
		lint_events = { "BufWrite", "CursorHold" },
	},

	textsubjects = {
		enable = true,
		keymaps = {
			[","] = "textsubjects-smart",
		},
	},

	--autopairs = {
	--    enable = true
	--},

	textobjects = {
		select = {
			enable = true,

			-- Automatically jump forward to textobj, similar to targets.vim
			lookahead = true,

			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["il"] = "@loop.outer",
				["al"] = "@loop.outer",
				["icd"] = "@conditional.inner",
				["acd"] = "@conditional.outer",
				["acm"] = "@comment.outer",
				["ast"] = "@statement.outer",
				["isc"] = "@scopename.inner",
				["iB"] = "@block.inner",
				["aB"] = "@block.outer",
				["p"] = "@parameter.inner",
			},
		},

		move = {
			enable = true,
			set_jumps = true, -- Whether to set jumps in the jumplist
			goto_next_start = {
				["gnf"] = "@function.outer",
				["gnif"] = "@function.inner",
				["gnp"] = "@parameter.inner",
				["gnc"] = "@call.outer",
				["gnic"] = "@call.inner",
			},
			goto_next_end = {
				["gnF"] = "@function.outer",
				["gniF"] = "@function.inner",
				["gnP"] = "@parameter.inner",
				["gnC"] = "@call.outer",
				["gniC"] = "@call.inner",
			},
			goto_previous_start = {
				["gpf"] = "@function.outer",
				["gpif"] = "@function.inner",
				["gpp"] = "@parameter.inner",
				["gpc"] = "@call.outer",
				["gpic"] = "@call.inner",
			},
			goto_previous_end = {
				["gpF"] = "@function.outer",
				["gpiF"] = "@function.inner",
				["gpP"] = "@parameter.inner",
				["gpC"] = "@call.outer",
				["gpiC"] = "@call.inner",
			},
		},
	},

	playground = {
		enable = true,
		updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
		persist_queries = false, -- Whether the query persists across vim sessions
		keybindings = {
			toggle_query_editor = "o",
			toggle_hl_groups = "i",
			toggle_injected_languages = "t",
			toggle_anonymous_nodes = "a",
			toggle_language_display = "I",
			focus_language = "f",
			unfocus_language = "F",
			update = "R",
			goto_node = "<cr>",
			show_help = "?",
		},
	},

	tree_docs = {
		enable = false, -- Currently experimental, doesn't work well
	},

	context_commentstring = {
		enable = true,
	},

	autotag = {
		enable = true,
		filetypes = { "html", "javascript", "javascriptreact", "typescriptreact", "svelte", "vue", "markdown" },
	},
})
