#!/usr/bin/env lua

local nats = require('nats')

-- Connect to NGS with credentials file
local client = nats.connect({
  host = 'connect.ngs.global',
  port = 4222,
  tls = false, -- NGS requires TLS
  -- TLS verification disabled for now (like the CLI default behavior)
  creds_path = os.getenv('HOME') .. '/.config/nats/context/NGS-Default-CLI.creds',
})

-- Enable trace to see the connection flow
client:enable_trace()

-- Connect and authenticate
client:connect()

print("Connected successfully!")

-- Test with a ping
if client:ping() then
  print("Ping successful!")
end

-- Subscribe to a test subject
client:subscribe("test.subject", function(message, reply)
  print("Received message:", message)
  if reply then
    client:publish(reply, "pong")
  end
end)

-- Publish a test message
client:publish("test.subject", "Hello from Lua NATS!")

-- Wait for messages
client:wait(1)

-- Cleanup
client:shutdown()
