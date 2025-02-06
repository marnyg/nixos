-- llm_edit_tree.lua

--- @class Node
--- @field text string
--- @field parent Node
--- @field children Node[]
--- @field modified number
--- @field note string

local Node = {}
Node.__index = Node


---@param parent Node|nil
---@param text string
function Node:new(text, parent)
  local node = {
    text = text,
    parent = parent,
    children = {},
    modified = os.time(),
    note = "" -- Optional user notes
  }
  return setmetatable(node, Node)
end

--- @class EditTree
--- @field root Node|nil
--- @field current Node|nil
--- @field branches Node[]
local EditTree = {
  root = nil,
  current = nil,
  branches = {} -- For quick access to different branches
}

local M = {}

function M.setup()
  -- Initialize the tree when the plugin is loaded
  M.initialize_tree("")

  -- Define user commands
  vim.api.nvim_create_user_command('LLMGenerate', function(opts)
    local input = M.get_current_text()
    local responses = M.query_llm(input, opts.args)
    M.create_branches(responses)
  end, { nargs = '?' })

  vim.api.nvim_create_user_command('LLMShowTree', function()
    M.render_tree()
  end, {})

  vim.api.nvim_create_user_command('LLMEditNode', function()
    M.start_editing_node(M.tree.current)
  end, {})

  vim.api.nvim_create_user_command('LLMSwitchBranch', function(opts)
    local branch_id = tonumber(opts.args)
    if branch_id and M.tree.branches[branch_id] then
      M.switch_branch(M.tree.branches[branch_id])
    else
      print("Invalid branch ID")
    end
  end, { nargs = 1 })
end

function M.get_current_text()
  return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
end

function M.query_llm(input, prompt)
  -- Replace with actual LLM API call
  return {
    "Generated response 1",
    "Alternative response 2",
    "Different approach 3"
  }
end

function M.create_branches(responses)
  local current = M.tree.current
  for _, response in ipairs(responses) do
    local node = Node:new(response, current)
    table.insert(current.children, node)
    table.insert(M.tree.branches, node)
  end
end

function M.switch_branch(node)
  M.tree.current = node
  M.apply_to_buffer(node.text)
end

function M.apply_to_buffer(text)
  local lines = vim.split(text, '\n')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

function M.start_editing_node(node)
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(node.text, '\n'))

  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = 80,
    height = 20,
    col = 10,
    row = 10,
    style = 'minimal'
  })

  vim.keymap.set('n', '<C-s>', function()
    node.text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
    node.modified = os.time()
    vim.api.nvim_buf_delete(buf, { force = true })
    M.apply_to_buffer(node.text)
  end, { buffer = buf })
end

function M.render_tree()
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = {}

  local function traverse(node, level)
    local prefix = string.rep('  ', level)
    local marker = (node == M.tree.current) and '▶ ' or '○ '
    table.insert(lines, prefix .. marker .. node.note)
    for _, child in ipairs(node.children) do
      traverse(child, level + 1)
    end
  end

  traverse(M.tree.root, 0)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = 40,
    height = 20,
    col = 0,
    row = 0,
    style = 'minimal'
  })
end

---@param initial_text string
function M.initialize_tree(initial_text)
  M.tree = {
    root = Node:new(initial_text, nil),
    current = nil,
    branches = {}
  }
  M.tree.current = M.tree.root
end

-- Initialize the tree when the plugin is loaded
M.initialize_tree("")

-- Autocommand to initialize the tree when a buffer is opened
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    if not M.tree then
      M.initialize_tree(M.get_current_text())
    end
  end
})

return M
