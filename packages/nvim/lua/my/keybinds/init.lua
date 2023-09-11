local map = vim.keymap.set

--vim.g.mapleader = " "

map("", "Q", "", {}) -- Begone, foul beast. I can invoke your wrath with gQ anyway.
map("", "<C-z>", "", {}) -- Begone, foul beast. I can invoke your wrath with gQ anyway.

map("n", "<F1>", ":e $MYVIMRC<CR>", {})
map("n", "<leader><F1>", " :source $MYVIMRC<CR>", {})

map("n", "<C-n>", " :NvimTreeToggle<CR>", {})
map("n", "<leader>.", " :lcd %:p:h<CR>", {})
map("", "<leader>w", ":w<CR>", {})

--require("my.keybinds.telescope")
--require("my.keybinds.lsp")
--require("my.keybinds.UI")
