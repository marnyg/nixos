-- llm_edit_tree.lua

--- @class Node
--- @field text string
--- @field parent Node|nil
--- @field children Node[]
--- @field modified number
--- @field note string

local Node = {}
Node.__index = Node

---@param text string
---@param parent Node|nil
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
--- @field root Node
--- @field current Node
--- @field branches table<number, Node>
local EditTree = {
  root = nil,
  current = nil,
  branches = {} -- For quick access to different branches
}

local M = {
  config = {
    llm_provider = nil,
    window = {
      width = 80,
      height = 20,
      border = 'rounded'
    },
    persist_file = vim.fn.stdpath('data') .. '/llm_edit_tree.json'
  }
}

function M.setup(user_config)
  M.config = vim.tbl_deep_extend('force', M.config, user_config or {})

  -- Initialize the tree when the plugin is loaded
  M.initialize_tree("")

  -- Define user commands
  local commands = {
    ['LLMGenerate'] = {
      func = function(opts)
        local input = M.get_current_text()
        local responses = M.query_llm(input, opts.args)
        if responses and #responses > 0 then
          M.create_branches(responses)
        else
          vim.notify("No responses generated", vim.log.levels.WARN)
        end
      end,
      opts = { nargs = '?' }
    },
    ['LLMShowTree'] = {
      func = M.render_tree,
      opts = {}
    },
    ['LLMEditNode'] = {
      func = function()
        if M.tree.current then
          M.start_editing_node(M.tree.current)
        end
      end,
      opts = {}
    },
    ['LLMSwitchBranch'] = {
      func = function(opts)
        local branch_id = tonumber(opts.args)
        if branch_id and M.tree.branches[branch_id] then
          M.switch_branch(M.tree.branches[branch_id])
        else
          vim.notify("Invalid branch ID", vim.log.levels.ERROR)
        end
      end,
      opts = { nargs = 1 }
    },
    ['LLMDeleteBranch'] = {
      func = function(opts)
        local branch_id = tonumber(opts.args)
        M.delete_branch(branch_id)
      end,
      opts = { nargs = 1 }
    },
    ['LLMSaveTree'] = {
      func = M.save_tree,
      opts = {}
    },
    ['LLMLoadTree'] = {
      func = M.load_tree,
      opts = {}
    }
  }

  for name, cmd in pairs(commands) do
    vim.api.nvim_create_user_command(name, cmd.func, cmd.opts)
  end

  -- Autocommand to save tree when leaving buffer
  vim.api.nvim_create_autocmd('BufLeave', {
    callback = function()
      if M.config.persist_file then
        M.save_tree()
      end
    end
  })
end

function M.get_current_text()
  return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
end

function M.query_llm(input, prompt)
  if M.config.llm_provider then
    return M.config.llm_provider(input, prompt)
  end

  -- Fallback mock responses
  return {
    "Generated response 1\nWith multiple lines",
    "Alternative response 2",
    "Different approach 3"
  }
end

function M.create_branches(responses)
  local current = M.tree.current
  if not current then return end

  current.children = {}
  for i, response in ipairs(responses) do
    local node = Node:new(response, current)
    table.insert(current.children, node)
    M.tree.branches[#M.tree.branches + 1] = node
  end
  M.switch_branch(current.children[1])
end

function M.switch_branch(node)
  if not node then return end
  M.tree.current = node
  M.apply_to_buffer(node.text)
  vim.notify("Switched to branch #" .. M.get_branch_id(node), vim.log.levels.INFO)
end

function M.get_branch_id(node)
  for id, n in pairs(M.tree.branches) do
    if n == node then return id end
  end
  return nil
end

function M.delete_branch(branch_id)
  local node = M.tree.branches[branch_id]
  if not node then return end

  -- Prevent deletion of root node
  if node == M.tree.root then
    vim.notify("Cannot delete root branch", vim.log.levels.ERROR)
    return
  end

  -- Remove from parent's children
  if node.parent then
    for i, child in ipairs(node.parent.children) do
      if child == node then
        table.remove(node.parent.children, i)
        break
      end
    end
  end

  -- Remove from branches list
  M.tree.branches[branch_id] = nil

  -- If deleting current branch, switch to parent
  if node == M.tree.current then
    M.switch_branch(node.parent or M.tree.root)
  end

  vim.notify("Deleted branch #" .. branch_id, vim.log.levels.INFO)
end

function M.apply_to_buffer(text)
  local lines = vim.split(text, '\n')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

function M.start_editing_node(node)
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(node.text, '\n'))

  local width = math.min(M.config.window.width, vim.o.columns - 4)
  local height = math.min(M.config.window.height, vim.o.lines - 4)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2 - 1,
    style = 'minimal',
    border = M.config.window.border
  })

  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true

  local save_and_close = function()
    node.text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
    node.modified = os.time()
    vim.api.nvim_win_close(win, true)
    M.apply_to_buffer(node.text)
  end

  vim.keymap.set('n', '<C-s>', save_and_close, { buffer = buf })
  vim.keymap.set('n', '<Esc>', function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end

function M.render_tree()
  if not M.tree or not M.tree.root then return end

  local buf = vim.api.nvim_create_buf(false, true)
  local lines = {}

  local function traverse(node, level)
    local prefix = string.rep('  ', level)
    local marker = (node == M.tree.current) and ' ' or ' '
    local note = node.note ~= "" and (" [" .. node.note .. "]") or ""
    local date = os.date("%H:%M", node.modified)
    local text_preview = #node.text > 20 and node.text:sub(1, 20) .. "..." or node.text
    table.insert(lines, string.format("%s%s %s%s | %s | %s",
      prefix, marker, M.get_branch_id(node) or "root", note, date, text_preview))
    for _, child in ipairs(node.children) do
      traverse(child, level + 1)
    end
  end

  traverse(M.tree.root, 0)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = 60
  local height = math.min(#lines + 2, vim.o.lines - 4)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2 - 1,
    style = 'minimal',
    border = M.config.window.border
  })

  vim.keymap.set('n', 'q', function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end

---@param initial_text string
function M.initialize_tree(initial_text)
  M.tree = {
    root = Node:new(initial_text, nil),
    current = nil,
    branches = {}
  }
  M.tree.current = M.tree.root
  M.tree.branches[1] = M.tree.root
end

function M.save_tree()
  if not M.config.persist_file or not M.tree then return end

  local data = {
    root = M.serialize_node(M.tree.root),
    current_id = M.get_branch_id(M.tree.current),
    branches = {}
  }

  for id, node in pairs(M.tree.branches) do
    data.branches[id] = M.serialize_node(node)
  end

  vim.fn.writefile({ vim.json.encode(data) }, M.config.persist_file)
end

function M.load_tree()
  if not M.config.persist_file or not vim.fn.filereadable(M.config.persist_file) then return end

  local data = vim.json.decode(table.concat(vim.fn.readfile(M.config.persist_file), '\n'))
  if not data then return end

  M.tree = {
    root = M.deserialize_node(data.root),
    current = nil,
    branches = {}
  }

  -- Rebuild branches table and fix parent references
  local node_map = {}
  local function build_map(node)
    node_map[M.get_node_id(node)] = node
    for _, child in ipairs(node.children) do
      build_map(child)
    end
  end
  build_map(M.tree.root)

  for id, serialized in pairs(data.branches) do
    local node = node_map[serialized.id]
    if node then
      M.tree.branches[id] = node
    end
  end

  M.tree.current = node_map[data.current_id] or M.tree.root
end

function M.serialize_node(node)
  return {
    id = M.get_node_id(node),
    text = node.text,
    parent_id = node.parent and M.get_node_id(node.parent),
    children = vim.tbl_map(M.serialize_node, node.children),
    modified = node.modified,
    note = node.note
  }
end

function M.deserialize_node(data)
  local node = Node:new(data.text)
  node.modified = data.modified
  node.note = data.note
  node.children = vim.tbl_map(M.deserialize_node, data.children)
  for _, child in ipairs(node.children) do
    child.parent = node
  end
  return node
end

function M.get_node_id(node)
  return tostring(node):match('0x(%x+)')
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
