#!/usr/bin/env lua

local basexx = require('basexx')

-- Create a 64-byte test string
local test_data = string.rep("x", 64)

-- Encode to base64
local encoded = basexx.to_base64(test_data)

-- Check for newlines
print("Encoded length: " .. #encoded)
print("Contains newline:", encoded:find("\n") ~= nil)
print("Encoded value:")
print(encoded)
print("---")

-- Try with our actual signature
local sig_hex = "268b0b8b22ba1bca873702480ae1628502e6f3686e53018d50b58187fb97c9759a5dfa84dac3e8bc23e309fca69bdbb4abef43f674084cb46f7d4980d7679009"
local sig_bytes = ""
for i = 1, #sig_hex, 2 do
  local byte_str = sig_hex:sub(i, i+1)
  sig_bytes = sig_bytes .. string.char(tonumber(byte_str, 16))
end

local sig_b64 = basexx.to_base64(sig_bytes)
print("Signature base64 length: " .. #sig_b64)
print("Signature contains newline:", sig_b64:find("\n") ~= nil)
print("Signature:")
print(sig_b64)
