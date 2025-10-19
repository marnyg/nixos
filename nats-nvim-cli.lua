-- NATS client for Neovim using the official NATS CLI
local M = {}

-- Store active subscriptions and jobs
M.subscriptions = {}
M.publishers = {}

-- Helper to parse NATS CLI output
local function parse_message(data)
  -- NATS CLI outputs in format: [#1] Received on "subject"
  -- Followed by the message content
  local result = {}
  local in_message = false
  local current_msg = {}

  for _, line in ipairs(data) do
    if line:match("^%[#%d+%] Received") then
      if #current_msg > 0 then
        table.insert(result, table.concat(current_msg, "\n"))
        current_msg = {}
      end
      in_message = true
    elseif in_message and line ~= "" then
      table.insert(current_msg, line)
    end
  end

  if #current_msg > 0 then
    table.insert(result, table.concat(current_msg, "\n"))
  end

  return result
end

-- Subscribe to a NATS subject
function M.subscribe(subject, callback, opts)
  opts = opts or {}

  local cmd = {
    "nats", "sub", subject,
    "--server", opts.server or "connect.ngs.global",
  }

  local buffer = {}
  local job_id = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      -- Accumulate data
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(buffer, line)
        end
      end

      -- Parse messages when we have complete data
      local messages = parse_message(buffer)
      for _, msg in ipairs(messages) do
        callback(msg, subject)
      end

      -- Keep only unparsed lines
      if #messages > 0 then
        buffer = {}
      end
    end,
    on_stderr = function(_, data, _)
      for _, line in ipairs(data) do
        if line ~= "" then
          vim.notify("NATS error: " .. line, vim.log.levels.ERROR)
        end
      end
    end,
    on_exit = function(_, exit_code, _)
      vim.notify("NATS subscription ended with code: " .. exit_code)
    end
  })

  M.subscriptions[job_id] = {
    subject = subject,
    job_id = job_id
  }

  return job_id
end

-- Publish to a NATS subject
function M.publish(subject, message, opts)
  opts = opts or {}

  local cmd = {
    "nats", "pub", subject, message,
    "--server", opts.server or "connect.ngs.global",
  }

  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code, _)
      if exit_code ~= 0 then
        vim.notify("Failed to publish to " .. subject, vim.log.levels.ERROR)
      end
    end
  })
end

-- Request-Reply pattern
function M.request(subject, message, callback, opts)
  opts = opts or {}

  local cmd = {
    "nats", "request", subject, message,
    "--server", opts.server or "connect.ngs.global",
    "--timeout", tostring(opts.timeout or 5) .. "s"
  }

  local response = {}
  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(response, line)
        end
      end
    end,
    on_exit = function(_, exit_code, _)
      if exit_code == 0 then
        callback(table.concat(response, "\n"))
      else
        callback(nil, "Request timeout or error")
      end
    end
  })
end

-- Unsubscribe from a subject
function M.unsubscribe(job_id)
  if M.subscriptions[job_id] then
    vim.fn.jobstop(job_id)
    M.subscriptions[job_id] = nil
  end
end

-- Unsubscribe from all
function M.unsubscribe_all()
  for job_id, _ in pairs(M.subscriptions) do
    vim.fn.jobstop(job_id)
  end
  M.subscriptions = {}
end

-- Stream-based subscription using coroutines
function M.stream(subject, opts)
  opts = opts or {}

  local co = coroutine.create(function()
    local buffer = {}
    local cmd = {
      "nats", "sub", subject,
      "--server", opts.server or "connect.ngs.global",
    }

    vim.fn.jobstart(cmd, {
      on_stdout = function(_, data, _)
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(buffer, line)
          end
        end

        local messages = parse_message(buffer)
        for _, msg in ipairs(messages) do
          coroutine.yield(msg)
        end
        buffer = {}
      end
    })
  end)

  return co
end

return M

