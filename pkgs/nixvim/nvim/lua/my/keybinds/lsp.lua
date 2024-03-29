local map = vim.keymap.set
local lspconfig = require("lspconfig")

local opts = { noremap = true, silent = true }
map("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
map("n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

map("n", "<leader>lds", "<cmd>Telescope lsp_document_symbols<cr>", { noremap = true, silent = true })
map("n", "<leader>lws", "<cmd>Telescope lsp_workspace_symbols<cr>", { noremap = true, silent = true })
map("n", "<leader>lwd", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { noremap = true, silent = true })
map("n", "<leader>ltd", "<cmd>Telescope lsp_type_definitions<cr>", { noremap = true, silent = true })
map("n", "<leader>lim", "<cmd>Telescope lsp_implementations<cr>", { noremap = true, silent = true })
map("n", "<leader>lic", "<cmd>Telescope lsp_incoming_calls<cr>", { noremap = true, silent = true })
map("n", "<leader>loc", "<cmd>Telescope lsp_outgoing_calls<cr>", { noremap = true, silent = true })
map("n", "<leader>ldf", "<cmd>Telescope lsp_definitions<cr>", { noremap = true, silent = true })
map("n", "<leader>lr", "<cmd>Telescope lsp_references<cr>", { noremap = true, silent = true })

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gK>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>wl",
    "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>lf", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
end

--cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- dynamically load lsps defined in the environment variable LSP_SERVERS
-- this is used in conjunction with direnv, using nix flakes to create a
-- shell where the lsps managed by nix and available in the path
local lsp_servers = os.getenv('LSP_SERVERS')
-- Check if the LSP_SERVERS environment variable is set
if lsp_servers then
    -- Split the LSP_SERVERS variable into separate server configurations
    for server_config in lsp_servers:gmatch("%S+") do
        -- Split the server configuration into the server name and the command
        local lsp_server, cmd = server_config:match("([^,]+),?([^,]*)")

        if lspconfig[lsp_server] then
            local setup_args = {
                on_attach = on_attach,
                capabilities = capabilities
            }
            if cmd ~= "" then
                setup_args.cmd = { cmd }
            end
            lspconfig[lsp_server].setup(setup_args)
        else
            print('LSP server ' .. lsp_server .. ' is not supported')
        end
    end
end

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local function toSnakeCase(str)
            return string.gsub(str, "%s*[- ]%s*", "_")
        end

        if client.name == 'omnisharp' then
            local tokenModifiers = client.server_capabilities.semanticTokensProvider.legend.tokenModifiers
            for i, v in ipairs(tokenModifiers) do
                tokenModifiers[i] = toSnakeCase(v)
            end
            local tokenTypes = client.server_capabilities.semanticTokensProvider.legend.tokenTypes
            for i, v in ipairs(tokenTypes) do
                tokenTypes[i] = toSnakeCase(v)
            end
        end
    end,
})

--local servers = {
----    bashls = "bash-language-server",
----    pylsp = "pylsp",
----    rust_analyzer = "rust_analyzer",
----    dockerls = "docker-langserver",
----    lua_ls = "lua-ls",
----    rnix = "rnix",
--    -- nomad_lsp = "nomad_lsp",
--}
--
--
--for server, cmd in pairs(servers) do
--    lspconfig[server].setup({ on_attach = on_attach })
--end
