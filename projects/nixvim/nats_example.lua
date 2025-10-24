-- Example usage of the NATS FFI module
-- This script demonstrates basic NATS operations using the FFI binding

-- Load the NATS FFI module
local nats = dofile("projects/nixvim/nats_ffi.lua")

-- Configuration
-- local NATS_URL = "nats://localhost:4222"

-- Authentication Configuration
-- Choose one of the following authentication methods (or nil for no auth):

-- 1. No authentication (for local development)
-- local AUTH = nil

-- 2. Credentials file (for NATS Cloud, NGS, or secured servers)
-- Uncomment and set path to your .creds file:
-- local AUTH = "/path/to/nats.creds"
-- For NGS (NATS Global Service):
local AUTH = "~/Downloads/NGS-Default-CLI.creds"
local NATS_URL = "tls://connect.ngs.global"

-- 3. Username and password
-- local AUTH = {user = "myuser", password = "mypassword"}

-- 4. Token authentication
-- local AUTH = {token = "my-secret-token"}

-- 5. Embedded JWT and seed (avoid hardcoding in production!)
-- local AUTH = {jwt_and_seed = [[
-- -----BEGIN NATS USER JWT-----
-- your.jwt.token.here
-- ------END NATS USER JWT------
--
-- -----BEGIN USER NKEY SEED-----
-- SUXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- ------END USER NKEY SEED------
-- ]]}

-- Example 1: Basic Connection and Publishing
local function example_publish(conn)
  print("=== Example 1: Basic Publishing ===")

  -- Publish a simple message
  conn:publish("test.subject", "Hello from Lua FFI!")
  print("Published message to 'test.subject'")

  -- Publish with JSON-like data
  local data = '{"name": "Lua FFI", "timestamp": ' .. os.time() .. '}'
  conn:publish("test.json", data)
  print("Published JSON message to 'test.json'")

  print("Publishing completed\n")
end

-- Example 2: Synchronous Subscribe (blocking)
local function example_subscribe_sync(conn)
  print("=== Example 2: Synchronous Subscribe ===")

  -- Create a synchronous subscription
  local sub = conn:subscribe_sync("test.>")
  print("Subscribed to 'test.>' - waiting for messages (timeout: 5s)...")

  -- In another terminal, publish to test.* subjects
  -- For testing in Neovim, you can publish from another buffer/window

  -- Wait for and process messages
  local count = 0
  local max_messages = 3

  while count < max_messages do
    local msg = sub:next_msg(5000) -- 5 second timeout
    if msg then
      print(string.format("Received message #%d:", count + 1))
      print("  Subject: " .. msg.subject)
      print("  Data: " .. msg.data)
      count = count + 1
    else
      print("No message received (timeout)")
      break
    end
  end

  -- Clean up
  sub:unsubscribe()
  print("Subscription closed\n")
end

-- Example 3: Request-Reply Pattern
local function example_request_reply()
  print("=== Example 3: Request-Reply Pattern ===")

  -- Create responder connection
  local responder = nats.Connection:new(NATS_URL, CREDENTIALS_FILE)

  -- Subscribe to service endpoint
  local service_sub = responder:subscribe_sync("service.echo")

  -- Create requester connection
  local requester = nats.Connection:new(NATS_URL, CREDENTIALS_FILE)

  -- Start a coroutine to handle the response
  local co = coroutine.create(function()
    local msg = service_sub:next_msg(5000)
    if msg then
      print("Service received: " .. msg.data)
      -- Echo the message back with prefix
      responder:publish(msg.reply, "Echo: " .. msg.data)
    end
  end)

  -- Resume the responder coroutine
  coroutine.resume(co)

  -- Send a request
  local reply = requester:request("service.echo", "Hello Service!", 5000)
  if reply then
    print("Got reply: " .. reply.data)
  else
    print("Request timed out")
  end

  -- Clean up
  service_sub:unsubscribe()
  responder:close()
  requester:close()
  print("Request-Reply example completed\n")
end

-- Example 4: Working with Multiple Subjects (Pub/Sub Pattern)
local function example_multi_subject(conn)
  print("=== Example 4: Multiple Subjects ===")

  -- Subscribe to multiple subjects using wildcards
  local subs = {
    conn:subscribe_sync("weather.>"),      -- All weather updates
    conn:subscribe_sync("news.sports.*"),  -- Sports news only
    conn:subscribe_sync("alerts.critical") -- Critical alerts
  }

  -- Publish to various subjects
  local messages = {
    { "weather.usa.ca",       "Sunny, 72°F" },
    { "weather.uk.london",    "Rainy, 15°C" },
    { "news.sports.football", "Team wins championship!" },
    { "news.sports.tennis",   "Grand slam final today" },
    { "news.politics",        "Election results" }, -- Won't be received
    { "alerts.critical",      "System maintenance at 2 AM" }
  }

  -- Publish all messages
  for _, msg in ipairs(messages) do
    conn:publish(msg[1], msg[2])
    print("Published to: " .. msg[1])
  end

  -- Collect messages from all subscriptions
  print("\nCollecting messages from subscriptions:")
  for i, sub in ipairs(subs) do
    local received = {}
    -- Try to get messages (non-blocking with short timeout)
    repeat
      local msg = sub:next_msg(100) -- 100ms timeout
      if msg then
        table.insert(received, { subject = msg.subject, data = msg.data })
      end
    until not msg

    -- Display received messages
    if #received > 0 then
      print(string.format("Subscription %d received:", i))
      for _, m in ipairs(received) do
        print(string.format("  [%s]: %s", m.subject, m.data))
      end
    end
  end

  -- Clean up
  for _, sub in ipairs(subs) do
    sub:unsubscribe()
  end
  print("\nMulti-subject example completed\n")
end

-- Example 5: Error Handling
local function example_error_handling()
  print("=== Example 5: Error Handling ===")

  -- Try to connect to an invalid server
  local success, result = pcall(function()
    return nats.Connection:new("nats://invalid-server:4222")
  end)

  if not success then
    print("Expected error when connecting to invalid server:")
    print("  " .. tostring(result))
  end

  -- Try to publish to a closed connection
  success, result = pcall(function()
    local conn = nats.Connection:new(NATS_URL, AUTH)
    conn:close()
    conn:publish("test", "This should fail")
  end)

  if not success then
    print("\nExpected error when publishing to closed connection:")
    print("  " .. tostring(result))
  end

  print("\nError handling example completed\n")
end

-- Example 7: Vim/Neovim Integration
local function example_vim_integration(conn)
  if not vim then
    print("=== Example 7: Vim Integration (skipped - not in Neovim) ===")
    return
  end

  print("=== Example 7: Vim Integration ===")

  -- Subscribe to editor events
  local sub = conn:subscribe_sync("editor.events")

  -- Publish current buffer info
  local buffer_info = {
    file = vim.fn.expand("%:p"),
    filetype = vim.bo.filetype,
    lines = vim.api.nvim_buf_line_count(0),
    modified = vim.bo.modified
  }

  local json = string.format(
    '{"file":"%s","filetype":"%s","lines":%d,"modified":%s}',
    buffer_info.file,
    buffer_info.filetype,
    buffer_info.lines,
    buffer_info.modified and "true" or "false"
  )

  conn:publish("editor.buffer.info", json)
  print("Published current buffer info to 'editor.buffer.info'")
  print("Buffer: " .. buffer_info.file)

  -- You could set up autocmds to publish events
  print("\nExample autocmd setup (not executed):")
  print([[
    vim.api.nvim_create_autocmd({"BufWritePost"}, {
        callback = function(ev)
            conn:publish("editor.file.saved", ev.file)
        end
    })
    ]])
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function(ev)
      conn:publish("editor.file.saved", ev.file)
    end
  })

  -- Clean up
  sub:unsubscribe()
  print("\nVim integration example completed\n")
end

-- Main execution
local function main()
  print("NATS FFI Example Usage")
  print("======================\n")

  -- Check if we can connect to NATS
  local test_conn = nil
  local connected = false

  local success = pcall(function()
    test_conn = nats.Connection:new(NATS_URL, AUTH)
    connected = true
  end)

  if test_conn then
    test_conn:close()
  end

  if not connected then
    print("WARNING: Could not connect to NATS server at " .. NATS_URL)
    print("Make sure NATS is running: nats-server or docker run -p 4222:4222 nats")
    print("\nRunning examples that don't require a connection...\n")

    -- Only run examples that don't require a connection
    example_error_handling()
    example_authentication()
  else
    print("Successfully connected to NATS at " .. NATS_URL .. "\n")

    -- Create ONE shared connection for all examples
    local conn = nats.Connection:new(NATS_URL, AUTH)

    -- Run all examples with the shared connection
    example_publish(conn)

    -- Note: For subscribe examples to work properly, you need to publish from another client
    print("NOTE: Subscribe examples work best with messages published from another client\n")

    example_subscribe_sync(conn)
    -- example_request_reply(conn)  -- Commented out - needs request() method
    example_multi_subject(conn)
    example_error_handling()
    example_vim_integration(conn)

    -- Close the shared connection at the end
    -- conn:close()
    print("\nClosed NATS connection")
  end

  print("All examples completed!")
end

-- Run the examples
main()

-- For interactive testing in Neovim:
-- Return the module so you can use it interactively
return nats
