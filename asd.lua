local nats = require 'nats'
local uuid = require 'uuid'

-- Initialize UUID with an RNG
local rng = require('uuid.rng')
uuid.set_rng(rng.math_random())

local params = {
  host = 'connect.ngs.global',
  -- host = 'localhost',
  port = 4222,
  -- NGS requires JWT authentication, not user/pass
  -- You need to use NKEY authentication for NGS
  nkey = 'SUAPXHUC6BJUYCTY42PHQF7PB66GZ4DEURFHY22YQOBKQQFL36EEYOFCPI',
  -- or use a JWT token if you have one
  -- token = 'your-jwt-token-here'
}


local client = nats.connect(params)

client:enable_trace()
client:connect()
--
-- client:publish('foo', 'bar A')
-- client:publish('foo', 'bar B')
-- -- client:ping()
--
-- local server_info = client:get_server_info()
--
-- for k, v in pairs(server_info) do
--   print(k, v)
-- end
--
local function subscribe_callback(payload)
  print('Received data: ' .. payload)
end

local subscribe_id = client:subscribe('foo', subscribe_callback)
client:wait(20)
print("done")
client:unsubscribe(subscribe_id)
