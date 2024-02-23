local map = vim.keymap.set

------------------------------NAVIGATION/UI--------------
-- better window movement
map("n", "<C-h>", "<C-w>h", { silent = true })
map("n", "<C-j>", "<C-w>j", { silent = true })
map("n", "<C-k>", "<C-w>k", { silent = true })
map("n", "<C-l>", "<C-w>l", { silent = true })

map("n", "<leader>ta", ":$tabnew<CR>", { noremap = true })
map("n", "<leader>tc", ":tabclose<CR>", { noremap = true })
map("n", "<leader>to", ":tabonly<CR>", { noremap = true })
map("n", "<leader>tn", ":tabn<CR>", { noremap = true })
map("n", "<leader>tp", ":tabp<CR>", { noremap = true })
-- move current tab to previous position
map("n", "<leader>tmp", ":-tabmove<CR>", { noremap = true })
-- move current tab to next position
map("n", "<leader>tmn", ":+tabmove<CR>", { noremap = true })

-- Tab switch buffer
map("n", "<TAB>", ":bnext<CR>", { noremap = true, silent = true })
map("n", "<S-TAB>", ":bprevious<CR>", { noremap = true, silent = true })

-- TODO fix this
-- Terminal window navigation
vim.cmd([[
  tnoremap <C-h> <C-\><C-N><C-w>h
  tnoremap <C-j> <C-\><C-N><C-w>j
  tnoremap <C-k> <C-\><C-N><C-w>k
  tnoremap <C-l> <C-\><C-N><C-w>l
  inoremap <C-h> <C-\><C-N><C-w>h
  inoremap <C-j> <C-\><C-N><C-w>j
  inoremap <C-k> <C-\><C-N><C-w>k
  inoremap <C-l> <C-\><C-N><C-w>l
  tnoremap <Esc> <C-\><C-n>
]])
-- resize with arrows
map("n", "<C-Up>", ":resize -2<CR>", { silent = true })
map("n", "<C-Down>", ":resize +2<CR>", { silent = true })
map("n", "<C-Left>", ":vertical resize -2<CR>", { silent = true })
map("n", "<C-Right>", ":vertical resize +2<CR>", { silent = true })

-- better indenting
map("v", ">", ">gv", { noremap = true, silent = true })
map("v", "<", "<gv", { noremap = true, silent = true })
--

-- Move selected line / block of text in visual mode
map("x", "K", ":move '<-2<CR>gv-gv", { noremap = true, silent = true })
map("x", "J", ":move '>+1<CR>gv-gv", { noremap = true, silent = true })

-- Better nav for omnicomplete
--vim.cmd('inoremap <expr> <c-j> (\"\\<C-n>\")')
--vim.cmd('inoremap <expr> <c-k> (\"\\<C-p>\")')

vim.cmd('vnoremap p "0p')
vim.cmd('vnoremap P "0P')
-- vim.api.nvim_set_keymap('v', 'p', '"0p', {silent = true})
-- vim.api.nvim_set_keymap('v', 'P', '"0P', {silent = true})
