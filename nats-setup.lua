-- NATS Setup for Neovim
-- Put this in your Neovim config or source it

-- 1. First, ensure you have the NATS CLI installed and credentials set
-- export NATS_CREDS=~/path/to/your/ngs.creds

-- Load the NATS module
local nats = require('nats-nvim-cli')

-- ===========================================================================
-- OPTION 1: Interactive Commands
-- ===========================================================================

-- Create a command to publish messages
vim.api.nvim_create_user_command('NatsPublish', function(opts)
  local args = vim.split(opts.args, ' ', { plain = false })
  local subject = args[1]
  local message = table.concat(vim.list_slice(args, 2), ' ')

  nats.publish(subject, message)
  vim.notify(string.format("Published to %s: %s", subject, message))
end, { nargs = '+', desc = 'Publish a message to NATS' })

-- Create a command to subscribe to a topic
vim.api.nvim_create_user_command('NatsSubscribe', function(opts)
  local subject = opts.args

  -- Create a dedicated buffer for messages
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, 'NATS: ' .. subject)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)

  -- Open in a split
  vim.cmd('split')
  vim.api.nvim_win_set_buf(0, buf)

  -- Subscribe and append messages to buffer
  local sub_id = nats.subscribe(subject, function(message)
    vim.schedule(function()
      local lines = vim.split(message, '\n')
      local timestamp = os.date('[%H:%M:%S]')
      table.insert(lines, 1, timestamp .. ' ' .. subject .. ':')
      table.insert(lines, '') -- blank line separator
      vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)

      -- Auto-scroll to bottom
      local win = vim.fn.bufwinid(buf)
      if win ~= -1 then
        vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
      end
    end)
  end)

  -- Store subscription ID in buffer variable for cleanup
  vim.api.nvim_buf_set_var(buf, 'nats_subscription', sub_id)

  -- Unsubscribe when buffer is deleted
  vim.api.nvim_create_autocmd('BufDelete', {
    buffer = buf,
    callback = function()
      nats.unsubscribe(sub_id)
      vim.notify('Unsubscribed from ' .. subject)
    end,
    once = true
  })

  vim.notify('Subscribed to ' .. subject)
end, { nargs = 1, desc = 'Subscribe to a NATS subject' })

-- ===========================================================================
-- OPTION 2: Code Execution Notifications
-- ===========================================================================

-- Notify on test runs
vim.api.nvim_create_autocmd('TermClose', {
  pattern = '*',
  callback = function()
    if vim.v.event.status == 0 then
      nats.publish('nvim.tests.passed', vim.json.encode({
        file = vim.fn.expand('%:p'),
        time = os.date()
      }))
    else
      nats.publish('nvim.tests.failed', vim.json.encode({
        file = vim.fn.expand('%:p'),
        exit_code = vim.v.event.status,
        time = os.date()
      }))
    end
  end
})

-- ===========================================================================
-- OPTION 3: LSP Events
-- ===========================================================================

vim.api.nvim_create_autocmd('DiagnosticChanged', {
  callback = function()
    local diagnostics = vim.diagnostic.get(0)
    if #diagnostics > 0 then
      nats.publish('nvim.diagnostics', vim.json.encode({
        file = vim.fn.expand('%:p'),
        count = #diagnostics,
        errors = vim.tbl_filter(function(d) return d.severity == 1 end, diagnostics),
        warnings = vim.tbl_filter(function(d) return d.severity == 2 end, diagnostics)
      }))
    end
  end
})

-- ===========================================================================
-- OPTION 4: Quick Test - Interactive REPL-like interface
-- ===========================================================================

vim.api.nvim_create_user_command('NatsRepl', function()
  -- Create a floating window for NATS interaction
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, 'NATS REPL')

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' NATS REPL ',
    title_pos = 'center'
  })

  -- Set initial content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    '-- NATS REPL --',
    '-- Commands:',
    '--   :NatsPub <subject> <message>  - Publish a message',
    '--   :NatsSub <subject>            - Subscribe to subject',
    '--   :NatsReq <subject> <message>  - Send request',
    '--   :q                            - Close REPL',
    '',
    '-- Output:',
    ''
  })

  -- Create buffer-local commands
  vim.api.nvim_buf_create_user_command(buf, 'NatsPub', function(opts)
    local args = vim.split(opts.args, ' ', { plain = false, trimempty = true })
    local subject = args[1]
    local message = table.concat(vim.list_slice(args, 2), ' ')

    nats.publish(subject, message)
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
      string.format('> Published to %s: %s', subject, message)
    })
  end, { nargs = '+' })

  vim.api.nvim_buf_create_user_command(buf, 'NatsSub', function(opts)
    local subject = opts.args
    local sub_id = nats.subscribe(subject, function(msg)
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
          string.format('< [%s] %s', subject, msg)
        })
      end)
    end)

    vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
      string.format('> Subscribed to %s (ID: %d)', subject, sub_id)
    })
  end, { nargs = 1 })

  vim.api.nvim_buf_create_user_command(buf, 'NatsReq', function(opts)
    local args = vim.split(opts.args, ' ', { plain = false, trimempty = true })
    local subject = args[1]
    local message = table.concat(vim.list_slice(args, 2), ' ')

    vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
      string.format('> Request to %s: %s', subject, message),
      '  Waiting for response...'
    })

    nats.request(subject, message, function(response, err)
      vim.schedule(function()
        if err then
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
            string.format('  ERROR: %s', err)
          })
        else
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
            string.format('  Response: %s', response)
          })
        end
      end)
    end)
  end, { nargs = '+' })
end, { desc = 'Open NATS REPL' })

-- ===========================================================================
-- OPTION 5: Status Line Integration
-- ===========================================================================

local nats_status = { connected = false, messages = 0 }

-- Subscribe to a status channel
nats.subscribe('nvim.status', function(msg)
  nats_status.messages = nats_status.messages + 1
  nats_status.last_message = msg
  vim.cmd('redrawstatus')
end)

-- Add to your statusline
-- Example for lualine:
-- sections = {
--   lualine_x = {
--     function()
--       return string.format('NATS: %d msgs', nats_status.messages)
--     end
--   }
-- }

print("NATS integration loaded. Commands available:")
print("  :NatsPublish <subject> <message>")
print("  :NatsSubscribe <subject>")
print("  :NatsRepl")

