local map = vim.keymap.set

map("n", "<leader>ff", "<cmd>Telescope git_files<cr>", { noremap = true, silent = true })
map("n", "<leader>fp", "<cmd>Telescope projects<cr>", { noremap = true, silent = true })
map("n", "<leader>fsa", "<cmd>Telescope live_grep<cr>", { noremap = true, silent = true })
map("n", "<leader>fsb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { noremap = true, silent = true })
map("n", "<leader>fj", "<cmd>Telescope jumplist<cr>", { noremap = true, silent = true })
map("n", "<leader>ft", "<cmd>Telescope treesitter<cr>", { noremap = true, silent = true })
map("n", "<leader>fgbb", "<cmd>Telescope git_branches<cr>", { noremap = true, silent = true })
map("n", "<leader>fgc", "<cmd>Telescope git_commits<cr>", { noremap = true, silent = true })
map("n", "<leader>fgbc", "<cmd>Telescope git_bcommits<cr>", { noremap = true, silent = true })
map("n", "<leader>fgs", "<cmd>Telescope git_status<cr>", { noremap = true, silent = true })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { noremap = true, silent = true })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { noremap = true, silent = true })

require("telescope").load_extension("projects")
require("telescope").load_extension("fzf")
require("telescope").setup({
	defaults = {
		-- Default configuration for telescope goes here:
		-- config_key = value,
		mappings = {
			i = {
				-- map actions.which_key to <C-h> (default: <C-/>)
				-- actions.which_key shows the mappings for your picker,
				-- e.g. git_{create, delete, ...}_branch for the git_branches picker
				--["<C-h>"] = "which_key",
                ["<c-e>"] = require('telescope.actions').to_fuzzy_refine
			},
            n = {
                ["<c-e>"] = require('telescope.actions').to_fuzzy_refine
            }
		},
	},
	pickers = {
		-- Default configuration for builtin pickers goes here:
		-- picker_name = {
		--   picker_config_key = value,
		--   ...
		-- }
		-- Now the picker_config_key will be applied every time you call this
		-- builtin picker
	},
	extensions = {
		-- Your extension configuration goes here:
		-- extension_name = {
		--   extension_config_key = value,
		-- }
		-- please take a look at the readme of the extension you want to configure
	},
})

