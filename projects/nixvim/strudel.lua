-- to use this code, there must be a server running on localhost:8080
-- you can run it with:
-- websocat ws-l:127.0.0.1:8080 broadcast:mirror: -0
--
--
local M = {}

-- http://lua-users.org/wiki/BaseSixtyFour
local dic = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
-- encoding
local function b64_encode(data)
  return (
    (data:gsub('.', function(x)
      local r, b = "", x:byte()
      for i = 8, 1, -1 do
        r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
      end
      return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
      if #x < 6 then
        return ""
      end
      local c = 0
      for i = 1, 6 do
        c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0)
      end
      return dic:sub(c + 1, c + 1)
    end) .. ({ "", '==', '=' })[#data % 3 + 1]
  )
end

local function ensure_websocket_server()
  vim.notify("Strudel: Trying to start server?", vim.log.levels.ERROR)
  local server_command = "websocat ws-l:127.0.0.1:8080 broadcast:mirror: --text -E "
  vim.fn.jobstart(server_command, {
    on_stderr = vim.print,
    -- on_stdout = vim.print,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify("Strudel: Server started!", vim.log.levels.INFO)
      else
        vim.notify("Strudel: Trying to pkill websocat server", vim.log.levels.ERROR)
        vim.fn.jobstart("pkill websocat")
      end
    end,
  })
end

local function send_code(code)
  if not code or #code == 0 then
    vim.notify("Strudel: No code to send.", vim.log.levels.WARN)
    return
  end

  -- Use printf for safety with special characters, and pipe to a new websocat
  -- CLIENT instance that connects to our SERVER instance.
  local command = string.format("printf '%%s' %s | websocat ws://localhost:8080", vim.fn.shellescape(code))

  -- Run the command asynchronously so it doesn't block nvim
  vim.fn.jobstart(command, {
    -- on_stderr = function(_, data) vim.notify("Strudel: Failed to send code to browser!", vim.log.levels.ERROR) end,
    on_stdout = function(_, _) vim.notify("Strudel: Code sent to browser!", vim.log.levels.INFO) end,
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        ensure_websocket_server()
      end
    end,
  })
end
-- Function to send a visual selection
function M.send_selection()
  local code = vim.fn.getreg('"') -- Get the yanked text from the default register
  send_code(code)
end

-- Function to send the entire buffer
function M.send_buffer()
  local code = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  code = b64_encode(code)
  send_code(code)
end

-- Function to send hush command (stops all sound)
function M.send_hush_command()
  local code = b64_encode("#hush")
  send_code(code)
end

--local strudel = require(��,'strudel')

-- Keymap for sending the entire file
-- Leader + s + a (send all)
--vim.keymap.set('n', '<leader>sa', strudel.send_buffer, { desc = "Strudel: Send All to browser" })
vim.keymap.set('n', '<leader>sa', M.send_buffer, { desc = "Strudel: Send All to browser" })
vim.keymap.set('n', '<leader>sh', M.send_hush_command, { desc = "Strudel: Send hush command to stop all sound" })

-- Keymap for sending a visual selection
-- After selecting text, press Leader + s + s (send selection)
--vim.keymap.set('v', '<leader>ss', '":lua require("strudel").send_selection()<CR>',
--{ desc = "Strudel: Send Selection to browser", silent = true })

-- File type associations for Strudel files
vim.filetype.add({
  extension = {
    strudel = 'javascript',
    str = 'javascript',
  },
})

return M
