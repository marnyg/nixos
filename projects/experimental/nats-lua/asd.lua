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
  -- nkey = 'SUAPXHUC6BJUYCTY42PHQF7PB66GZ4DEURFHY22YQOBKQQFL36EEYOFCPI',
  -- or use a JWT token if you have one
  token =
  'eyJ0eXAiOiJKV1QiLCJhbGciOiJlZDI1NTE5LW5rZXkifQ.eyJqdGkiOiJUUEVENTVVTUtPTjJHT0ZMQ0VTUkEyWEhEVkgzNUdES1dUNU9PNFpDUllCTEFDQ0ZGRTdRIiwiaWF0IjoxNzU5NzQ3OTc2LCJpc3MiOiJBQ0tSRUNOTkJCVUJRR01ZWDc0SVVFTkpUN0FLNE1LSjNKNjVDNU1EU1RBNTRPNFZRWVFXRlBPMiIsIm5hbWUiOiJDTEkiLCJzdWIiOiJVQlRKNVFYUUsyNU1URkFTSVEyR001UklRSENPSU81RFBaRTNKRDQzRkEzUEVYUFY2R1YzVUE0SSIsIm5hdHMiOnsicHViIjp7fSwic3ViIjp7fSwic3VicyI6LTEsImRhdGEiOi0xLCJwYXlsb2FkIjotMSwiaXNzdWVyX2FjY291bnQiOiJBQldFMlVXV0JLWEtXWEpUMko3RlZDTktHUzNSRUdFQ1NXS0VKRFlRTEk0N0FNRERTS1dOQ01BNCIsInR5cGUiOiJ1c2VyIiwidmVyc2lvbiI6Mn19.9XALvae7Xd0fMti6nzUCudRszt1Xz_ePTd2YwqL9jGIKSYfMdh_HA_5m6v8XJ5fwP3CFwdWzb4xNopiSEPtQCA'
}


local client = nats.connect(params)

client:enable_trace()
client:connect()
--
client:publish('foo', 'bar A')
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
