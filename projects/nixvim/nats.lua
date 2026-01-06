local nats = {
  _VERSION     = 'lua-nats 0.0.5',
  _DESCRIPTION = 'LUA client for NATS messaging system. https://nats.io',
  _COPYRIGHT   = 'Copyright (C) 2015 Eric Pinto',
}


-- ### Library requirements ###

local cjson = require('cjson')
local uuid  = require('uuid')
local bit   = require('bit') -- LuaJIT bitwise operations
local ffi   = require('ffi') -- LuaJIT FFI for direct OpenSSL calls
local basexx                 -- lazy load for base32 (optional dependency)
local resty_openssl          -- lazy load for ed25519 (optional dependency)

-- set the random number generator for /dev/urandom. On Windows this isn't available
-- and it returns nil+error, which is passed on to set_rng which then
-- throws a meaningful error.
uuid.set_rng(uuid.rng.urandom())

-- ### Local properties ###

local unpack = _G.unpack or table.unpack
local network, request, response, command = {}, {}, {}, {}

local client_prototype = {
  user          = nil,
  pass          = nil,
  lang          = 'lua',
  version       = '0.0.5',
  verbose       = false,
  pedantic      = false,
  trace         = false,
  reconnect     = true,
  subscriptions = {},
  information   = {},
}

local defaults = {
  host        = '127.0.0.1',
  port        = 4222,
  tcp_nodelay = true,
  path        = nil,
  tls         = false,
  tls_ca_path = nil,
  tls_ca_file = nil,
  tls_cert    = nil,
  tls_key     = nil,
  creds_path  = nil,
}

-- ### NKEY and Credentials utilities ###

-- FFI definitions for OpenSSL Ed25519 signing and key extraction
ffi.cdef [[
    typedef struct evp_pkey_st EVP_PKEY;
    typedef struct evp_md_ctx_st EVP_MD_CTX;
    typedef struct evp_md_st EVP_MD;
    typedef struct engine_st ENGINE;

    int EVP_PKEY_get_raw_public_key(const EVP_PKEY *pkey, unsigned char *pub, size_t *len);
    int EVP_PKEY_get_raw_private_key(const EVP_PKEY *pkey, unsigned char *priv, size_t *len);

    EVP_PKEY *EVP_PKEY_new_raw_private_key(int type, ENGINE *e,
                                            const unsigned char *priv, size_t len);
    void EVP_PKEY_free(EVP_PKEY *pkey);

    EVP_MD_CTX *EVP_MD_CTX_new(void);
    void EVP_MD_CTX_free(EVP_MD_CTX *ctx);
    int EVP_DigestSignInit(EVP_MD_CTX *ctx, void **pctx, const EVP_MD *type,
                            ENGINE *e, EVP_PKEY *pkey);
    int EVP_DigestSign(EVP_MD_CTX *ctx, unsigned char *sigret, size_t *siglen,
                       const unsigned char *tbs, size_t tbslen);
]]

-- EVP_PKEY type constants
local NID_ED25519 = 1087

-- Lazy load crypto libraries
local function init_crypto_libs()
  if not basexx then
    local ok, lib = pcall(require, 'basexx')
    if not ok then
      return nil, "basexx library not found"
    end
    basexx = lib
  end

  if not resty_openssl then
    local ok, openssl = pcall(require, 'resty.openssl')
    if not ok then
      return nil, "lua-resty-openssl library not found"
    end

    -- Load required modules
    local ok2, pkey = pcall(require, 'resty.openssl.pkey')
    if not ok2 then
      return nil, "lua-resty-openssl.pkey not found"
    end

    resty_openssl = {
      openssl = openssl,
      pkey = pkey,
    }
  end

  return true
end

-- CRC16 lookup table (CCITT/XMODEM polynomial)
local crc16tab = {
  0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7,
  0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef,
  0x1231, 0x0210, 0x3273, 0x2252, 0x52b5, 0x4294, 0x72f7, 0x62d6,
  0x9339, 0x8318, 0xb37b, 0xa35a, 0xd3bd, 0xc39c, 0xf3ff, 0xe3de,
  0x2462, 0x3443, 0x0420, 0x1401, 0x64e6, 0x74c7, 0x44a4, 0x5485,
  0xa56a, 0xb54b, 0x8528, 0x9509, 0xe5ee, 0xf5cf, 0xc5ac, 0xd58d,
  0x3653, 0x2672, 0x1611, 0x0630, 0x76d7, 0x66f6, 0x5695, 0x46b4,
  0xb75b, 0xa77a, 0x9719, 0x8738, 0xf7df, 0xe7fe, 0xd79d, 0xc7bc,
  0x48c4, 0x58e5, 0x6886, 0x78a7, 0x0840, 0x1861, 0x2802, 0x3823,
  0xc9cc, 0xd9ed, 0xe98e, 0xf9af, 0x8948, 0x9969, 0xa90a, 0xb92b,
  0x5af5, 0x4ad4, 0x7ab7, 0x6a96, 0x1a71, 0x0a50, 0x3a33, 0x2a12,
  0xdbfd, 0xcbdc, 0xfbbf, 0xeb9e, 0x9b79, 0x8b58, 0xbb3b, 0xab1a,
  0x6ca6, 0x7c87, 0x4ce4, 0x5cc5, 0x2c22, 0x3c03, 0x0c60, 0x1c41,
  0xedae, 0xfd8f, 0xcdec, 0xddcd, 0xad2a, 0xbd0b, 0x8d68, 0x9d49,
  0x7e97, 0x6eb6, 0x5ed5, 0x4ef4, 0x3e13, 0x2e32, 0x1e51, 0x0e70,
  0xff9f, 0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a, 0x9f59, 0x8f78,
  0x9188, 0x81a9, 0xb1ca, 0xa1eb, 0xd10c, 0xc12d, 0xf14e, 0xe16f,
  0x1080, 0x00a1, 0x30c2, 0x20e3, 0x5004, 0x4025, 0x7046, 0x6067,
  0x83b9, 0x9398, 0xa3fb, 0xb3da, 0xc33d, 0xd31c, 0xe37f, 0xf35e,
  0x02b1, 0x1290, 0x22f3, 0x32d2, 0x4235, 0x5214, 0x6277, 0x7256,
  0xb5ea, 0xa5cb, 0x95a8, 0x8589, 0xf56e, 0xe54f, 0xd52c, 0xc50d,
  0x34e2, 0x24c3, 0x14a0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
  0xa7db, 0xb7fa, 0x8799, 0x97b8, 0xe75f, 0xf77e, 0xc71d, 0xd73c,
  0x26d3, 0x36f2, 0x0691, 0x16b0, 0x6657, 0x7676, 0x4615, 0x5634,
  0xd94c, 0xc96d, 0xf90e, 0xe92f, 0x99c8, 0x89e9, 0xb98a, 0xa9ab,
  0x5844, 0x4865, 0x7806, 0x6827, 0x18c0, 0x08e1, 0x3882, 0x28a3,
  0xcb7d, 0xdb5c, 0xeb3f, 0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a,
  0x4a75, 0x5a54, 0x6a37, 0x7a16, 0x0af1, 0x1ad0, 0x2ab3, 0x3a92,
  0xfd2e, 0xed0f, 0xdd6c, 0xcd4d, 0xbdaa, 0xad8b, 0x9de8, 0x8dc9,
  0x7c26, 0x6c07, 0x5c64, 0x4c45, 0x3ca2, 0x2c83, 0x1ce0, 0x0cc1,
  0xef1f, 0xff3e, 0xcf5d, 0xdf7c, 0xaf9b, 0xbfba, 0x8fd9, 0x9ff8,
  0x6e17, 0x7e36, 0x4e55, 0x5e74, 0x2e93, 0x3eb2, 0x0ed1, 0x1ef0,
}

-- CRC16 calculation for NKEY validation (CCITT/XMODEM)
local function crc16(data)
  local crc = 0
  for i = 1, #data do
    local byte = data:byte(i)
    local idx = bit.band(bit.bxor(bit.rshift(crc, 8), byte), 0xFF) + 1
    crc = bit.band(bit.bxor(bit.lshift(crc, 8), crc16tab[idx]), 0xFFFF)
  end
  return crc
end

-- Decode NKEY with validation
local function decode_nkey(nkey)
  local ok, err = init_crypto_libs()
  if not ok then
    return nil, err
  end

  -- Decode from base32
  local decoded = basexx.from_base32(nkey, basexx.RFC4648)
  if not decoded then
    return nil, "failed to decode base32"
  end

  -- Determine prefix length (seeds have 2-byte prefix, public keys have 1-byte)
  local first_byte = decoded:byte(1)
  local prefix_len = 1

  -- Check if it's a seed (prefix byte in 0x90-0x97 range for 'S' prefix)
  -- Seeds start with 'S' which is 18 in base32, encoded as (18<<3) = 144 = 0x90
  if bit.band(first_byte, 0xF8) == 0x90 then
    prefix_len = 2
  end

  -- Extract prefix, payload, and checksum
  local payload_len = #decoded - prefix_len - 2
  local payload = decoded:sub(prefix_len + 1, prefix_len + payload_len)
  local checksum_start = prefix_len + payload_len + 1
  local checksum = bit.bor(decoded:byte(checksum_start), bit.lshift(decoded:byte(checksum_start + 1), 8))

  -- Validate checksum
  local expected_crc = crc16(decoded:sub(1, prefix_len + payload_len))
  if checksum ~= expected_crc then
    return nil, "checksum validation failed"
  end

  return payload, first_byte
end

-- Encode NKEY with prefix and checksum
local function encode_nkey(prefix, payload)
  local ok, err = init_crypto_libs()
  if not ok then
    return nil, err
  end

  local data = string.char(prefix) .. payload
  local checksum = crc16(data)
  local full_data = data .. string.char(bit.band(checksum, 0xFF), bit.band(bit.rshift(checksum, 8), 0xFF))
  return basexx.to_base32(full_data, basexx.RFC4648)
end

-- Sign nonce with NKEY seed for authentication
local function sign_nonce(nonce, nkey_seed)
  local ok, err = init_crypto_libs()
  if not ok then
    return nil, err
  end

  -- Decode the NKEY seed
  local seed_bytes, prefix = decode_nkey(nkey_seed)
  if not seed_bytes then
    return nil, "failed to decode NKEY seed: " .. tostring(prefix)
  end

  -- Debug: print seed in hex
  local seed_hex = ""
  for i = 1, #seed_bytes do
    seed_hex = seed_hex .. string.format("%02x", seed_bytes:byte(i))
  end
  print("DEBUG seed hex: " .. seed_hex)

  -- Debug: print nonce in hex
  local nonce_hex = ""
  for i = 1, #nonce do
    nonce_hex = nonce_hex .. string.format("%02x", nonce:byte(i))
  end
  print("DEBUG nonce hex: " .. nonce_hex)

  -- Create Ed25519 private key from raw seed using OpenSSL FFI
  -- IMPORTANT: Convert Lua string to FFI byte array to handle NULL bytes correctly
  -- C functions treat strings as NULL-terminated, but our seed may contain 0x00 bytes
  local seed_buf = ffi.new("unsigned char[32]")
  ffi.copy(seed_buf, seed_bytes, 32)

  local pkey = ffi.C.EVP_PKEY_new_raw_private_key(NID_ED25519, nil, seed_buf, 32)
  if pkey == nil then
    return nil, "failed to create Ed25519 key from raw seed"
  end

  -- Sign the nonce using FFI for pure Ed25519 PureEdDSA
  -- We use FFI to ensure we're calling OpenSSL correctly with NULL digest
  local md_ctx = ffi.C.EVP_MD_CTX_new()
  if md_ctx == nil then
    ffi.C.EVP_PKEY_free(pkey)
    return nil, "failed to create EVP_MD_CTX"
  end

  -- Initialize digest signing with NULL digest for PureEdDSA
  local ret = ffi.C.EVP_DigestSignInit(md_ctx, nil, nil, nil, pkey)
  if ret ~= 1 then
    ffi.C.EVP_MD_CTX_free(md_ctx)
    ffi.C.EVP_PKEY_free(pkey)
    return nil, "failed to initialize Ed25519 signing context"
  end

  -- Convert nonce to FFI byte array (same reason as seed - handle NULL bytes)
  local nonce_buf = ffi.new("unsigned char[?]", #nonce)
  ffi.copy(nonce_buf, nonce, #nonce)

  -- Get signature length
  local sig_len = ffi.new("size_t[1]")
  ret = ffi.C.EVP_DigestSign(md_ctx, nil, sig_len, nonce_buf, #nonce)
  if ret ~= 1 then
    ffi.C.EVP_MD_CTX_free(md_ctx)
    ffi.C.EVP_PKEY_free(pkey)
    return nil, "failed to get signature length"
  end

  -- Allocate buffer and sign
  local sig_buf = ffi.new("unsigned char[?]", sig_len[0])
  ret = ffi.C.EVP_DigestSign(md_ctx, sig_buf, sig_len, nonce_buf, #nonce)

  -- Clean up OpenSSL resources
  ffi.C.EVP_MD_CTX_free(md_ctx)
  ffi.C.EVP_PKEY_free(pkey)

  if ret ~= 1 then
    return nil, "failed to sign nonce"
  end

  local signature = ffi.string(sig_buf, sig_len[0])

  -- Debug: check signature length
  print(string.format("DEBUG: nonce length: %d bytes", #nonce))
  print(string.format("DEBUG: signature length: %d bytes (expected 64 for Ed25519)", #signature))
  print(string.format("DEBUG: seed length: %d bytes (expected 32)", #seed_bytes))

  -- Debug: print signature in hex
  local sig_hex = ""
  for i = 1, #signature do
    sig_hex = sig_hex .. string.format("%02x", signature:byte(i))
  end
  print("DEBUG signature hex: " .. sig_hex)

  -- Return URL-safe base64-encoded signature (NATS requirement)
  -- Convert standard base64 to URL-safe: + -> -, / -> _, remove padding
  local sig_b64 = basexx.to_base64(signature)
  local sig_url_safe = sig_b64:gsub('+', '-'):gsub('/', '_'):gsub('=', '')
  return sig_url_safe
end

-- Load credentials from file
local function load_credentials(filepath)
  local file, err = io.open(filepath, "r")
  if not file then
    return nil, "failed to open credentials file: " .. (err or "unknown error")
  end

  local content = file:read("*all")
  file:close()

  -- Extract JWT
  local jwt = content:match("%-%-%-%-%-BEGIN NATS USER JWT%-%-%-%-%-\n(.-)\n%-%-%-%-%-%-END NATS USER JWT%-%-%-%-%-%-")

  -- Extract NKEY seed
  local nkey_seed = content:match(
    "%-%-%-%-%-BEGIN USER NKEY SEED%-%-%-%-%-\n(.-)\n%-%-%-%-%-%-END USER NKEY SEED%-%-%-%-%-%-")

  if not jwt or not nkey_seed then
    return nil, "failed to parse credentials file"
  end

  -- Trim whitespace from JWT and NKEY seed
  jwt = jwt:match("^%s*(.-)%s*$")
  nkey_seed = nkey_seed:match("^%s*(.-)%s*$")

  return {
    jwt = jwt,
    nkey_seed = nkey_seed,
  }
end

-- ### Create a properly formatted inbox subject.

local function create_inbox()
  return '_INBOX.' .. uuid()
end

-- ### Local methods ###

local function merge_defaults(parameters)
  if parameters == nil then
    parameters = {}
  end
  for k, _ in pairs(defaults) do
    if parameters[k] == nil then
      parameters[k] = defaults[k]
    end
  end
  return parameters
end

local function load_methods(proto, commands)
  -- inherit client metatable from client_proto metatable
  local client = setmetatable({}, getmetatable(proto))

  -- Assign commands functions to the client
  for cmd, fn in pairs(commands) do
    if type(fn) ~= 'function' then
      nats.error('invalid type for command ' .. cmd .. '(must be a function)')
    end
    client[cmd] = fn
  end

  -- assing client properties and methods from client_proto
  for i, v in pairs(proto) do
    client[i] = v
  end

  return client
end

local function create_client(client_proto, client_socket, commands, parameters)
  local client = load_methods(client_proto, commands)
  -- assign client error handler
  client.error = nats.error
  -- keep parameters around, for TLS
  client.parameters = parameters
  -- assign client network methods
  client.network = {
    socket = client_socket,
    read   = network.read,
    write  = network.write,
    lread  = nil,
    lwrite = nil,
  }
  -- assign client requests methods
  client.requests = {
    multibulk = request.raw,
  }
  uuid.seed()
  return client
end

-- ### Network methods ###

function network.write(client, buffer)
  if client.trace then print('->> ' .. buffer:sub(1, -3)) end
  local _, err = client.network.socket:send(buffer)
  if not err then
    client.network.lwrite = buffer
  else
    client.error(err)
  end
end

function network.read(client, len)
  if len == nil then len = '*l' end
  local line, err = client.network.socket:receive(len)
  if client.trace and line then print('<<- ' .. line) end
  if line and not err then
    client.network.lread = line
    return line
  else
    client.error('connection error: ' .. (err or 'connection closed'))
  end
end

-- ### Response methods ###

-- Client response reader
function response.read(client)
  local payload = client.network.read(client)
  local slices  = {}
  local data    = {}

  for slice in payload:gmatch('[^%s]+') do
    table.insert(slices, slice)
  end

  -- PING
  if slices[1] == 'PING' then
    data.action = 'PING'

    -- PONG
  elseif slices[1] == 'PONG' then
    data.action = 'PONG'

    -- MSG
  elseif slices[1] == 'MSG' then
    data.action    = 'MSG'
    data.subject   = slices[2]
    data.unique_id = slices[3]
    -- ask for line ending chars and remove them
    if #slices == 4 then
      data.content = client.network.read(client, slices[4] + 2):sub(1, -3)
    else
      data.reply   = slices[4]
      data.content = client.network.read(client, slices[5] + 2):sub(1, -3)
    end

    -- INFO
  elseif slices[1] == 'INFO' then
    data.action  = 'INFO'
    data.content = slices[2]

    -- INFO
  elseif slices[1] == '+OK' then
    data.action = 'OK'

    -- INFO
  elseif slices[1] == '-ERR' then
    data.action = 'ERROR'
    -- data.content = slices[2]

    -- unknown type of reply
  else
    data = client.error('unknown response: ' .. payload)
  end

  return data
end

-- ### Request methods ###

-- Client request sender (RAW)
function request.raw(client, buffer)
  local bufferType = type(buffer)

  if bufferType == 'table' then
    client.network.write(client, table.concat(buffer))
  elseif bufferType == 'string' then
    client.network.write(client, buffer)
  else
    client.error('argument error: ' .. bufferType)
  end
end

-- ### Client prototype methods ###

client_prototype.raw_cmd = function(client, buffer)
  request.raw(client, buffer .. '\r\n')
  return response.read(client)
end

client_prototype.set_auth = function(client, user, pass)
  client.user = user
  client.pass = pass
end

client_prototype.enable_trace = function(client)
  client.trace = true
end

client_prototype.set_verbose = function(client, verbose)
  client.verbose = verbose
end

client_prototype.set_pedantic = function(client, pedantic)
  client.pedantic = pedantic
end

client_prototype.count_subscriptions = function(client)
  return #client.subscriptions
end

client_prototype.get_server_info = function(client)
  return client.information
end

client_prototype.upgrade_to_tls = function(client)
  local status, luasec = pcall(require, 'ssl')
  if not status then
    nats.error('TLS is required but the luasec library is not available')
  end
  local params = {
    capath = client.parameters.tls_ca_path,
    cafile = client.parameters.tls_ca_file,
    certificate = client.parameters.tls_cert,
    key = client.parameters.tls_key,
    mode = "client",
    options = { "all", "no_sslv3", "no_sslv2" },
    protocol = "any",                                -- Allow any TLS version
    verify = client.parameters.tls_verify or "none", -- Default to no verification for easier testing
  }

  client.network.socket = luasec.wrap(client.network.socket, params)
  local ok, err = client.network.socket:dohandshake()
  if not ok then
    nats.error('TLS handshake failed: ' .. tostring(err))
  end
end

client_prototype.shutdown = function(client)
  client.network.socket:shutdown()
end

-- ### Socket connection methods ###

local function connect_tcp(socket, parameters)
  local host, port = parameters.host, tonumber(parameters.port)
  if parameters.timeout then
    socket:settimeout(parameters.timeout, 't')
  end

  local ok, err = socket:connect(host, port)
  if not ok then
    nats.error('could not connect to ' .. host .. ':' .. port .. ' [' .. err .. ']')
  end
  socket:setoption('tcp-nodelay', parameters.tcp_nodelay)
  return socket
end

local function connect_unix(socket, parameters)
  local ok, err = socket:connect(parameters.path)
  if not ok then
    nats.error('could not connect to ' .. parameters.path .. ' [' .. err .. ']')
  end
  return socket
end

local function create_connection(parameters)
  if parameters.socket then
    return parameters.socket
  end

  local perform_connection, socket

  if parameters.scheme == 'unix' then
    perform_connection, socket = connect_unix, require('socket.unix')
    assert(socket, 'your build of LuaSocket does not support UNIX domain sockets')
  else
    if parameters.scheme then
      local scheme = parameters.scheme
      assert(scheme == 'nats' or scheme == 'tcp' or scheme == 'tls', 'invalid scheme: ' .. scheme)
      if scheme == 'tls' then
        parameters.tls = true
      end
    end
    perform_connection, socket = connect_tcp, require('socket').tcp
  end

  return perform_connection(socket(), parameters)
end

-- ### Nats library methods ###

function nats.error(message, level)
  error(message, (level or 1) + 1)
end

function nats.connect(...)
  local args, parameters = { ... }, nil

  if #args == 1 then
    parameters = args[1]
  elseif #args > 1 then
    local host, port, timeout = unpack(args)
    parameters = { host = host, port = port, timeout = tonumber(timeout) }
  end

  local commands = nats.commands or {}
  if type(commands) ~= 'table' then
    nats.error('invalid type for the commands table')
  end

  local socket = create_connection(merge_defaults(parameters))
  local client = create_client(client_prototype, socket, commands, parameters)

  return client
end

function nats.command(cmd, opts)
  return command(cmd, opts)
end

-- ### Command methods ###

function command.connect(client)
  -- Create a fresh table without any metatables for cjson
  local config = {}
  config.lang = client.lang
  config.version = client.version
  config.verbose = client.verbose
  config.pedantic = client.pedantic
  config.tls_required = client.parameters.tls

  -- gather the server information
  local data = response.read(client)
  if data.action == 'INFO' then
    client.information = cjson.decode(data.content)

    -- Handle TLS upgrade before authentication
    if client.parameters.tls or client.information['tls_required'] then
      if (client.information['tls_available'] or client.information['tls_required']) then
        client:upgrade_to_tls()
      else
        nats.error('TLS is required but not offered by the server')
      end
    end

    -- Check for JWT/NKEY authentication via credentials file
    if client.parameters.creds_path then
      local creds, err = load_credentials(client.parameters.creds_path)
      if not creds then
        nats.error('failed to load credentials: ' .. err)
      end

      -- Extract nonce from server info
      local nonce_b64 = client.information['nonce']
      if not nonce_b64 then
        nats.error('server did not provide nonce for NKEY authentication')
      end

      -- Initialize crypto libraries (loads basexx)
      local ok, err = init_crypto_libs()
      if not ok then
        nats.error('failed to initialize crypto libraries: ' .. err)
      end

      -- Decode nonce from base64 before signing
      -- Convert from URL-safe base64 to standard and add padding if needed
      local nonce_std = nonce_b64:gsub('-', '+'):gsub('_', '/')
      local padding = (4 - #nonce_std % 4) % 4
      nonce_std = nonce_std .. string.rep('=', padding)

      local nonce_bytes = basexx.from_base64(nonce_std)
      if not nonce_bytes then
        nats.error('failed to decode nonce from base64')
      end

      -- Extract the public key from JWT's "sub" field
      local jwt_parts = {}
      for part in creds.jwt:gmatch('[^.]+') do
        table.insert(jwt_parts, part)
      end

      local nkey = nil
      if #jwt_parts >= 2 then
        -- Convert URL-safe base64 to standard and add padding
        local b64 = jwt_parts[2]:gsub('-', '+'):gsub('_', '/')
        local padding = (4 - #b64 % 4) % 4
        b64 = b64 .. string.rep('=', padding)

        local jwt_payload = basexx.from_base64(b64)
        if jwt_payload then
          local jwt_data = cjson.decode(jwt_payload)
          if jwt_data and jwt_data.sub then
            nkey = jwt_data.sub
            if client.trace then
              print("DEBUG Using public key from JWT: " .. nkey)
            end
          end
        end
      end

      if not nkey then
        nats.error('failed to extract public key from JWT')
      end

      -- Verify that the seed corresponds to the public key in JWT
      if client.trace then
        -- Decode the seed and derive its public key to verify
        local seed_bytes, prefix = decode_nkey(creds.nkey_seed)
        if seed_bytes then
          -- Create Ed25519 key from raw seed (use FFI byte array for NULL byte safety)
          local verify_seed_buf = ffi.new("unsigned char[32]")
          ffi.copy(verify_seed_buf, seed_bytes, 32)
          local verify_pkey = ffi.C.EVP_PKEY_new_raw_private_key(NID_ED25519, nil, verify_seed_buf, 32)
          if verify_pkey ~= nil then
            local pub_buf = ffi.new("unsigned char[32]")
            local len_buf = ffi.new("size_t[1]", 32)
            local ret = ffi.C.EVP_PKEY_get_raw_public_key(verify_pkey, pub_buf, len_buf)
            if ret == 1 then
              local public_key_raw = ffi.string(pub_buf, len_buf[0])
              local derived_nkey = encode_nkey(0xA0, public_key_raw)
              print("DEBUG Derived public key from seed: " .. (derived_nkey or "nil"))
              if derived_nkey ~= nkey then
                print("ERROR: Seed does not correspond to JWT's public key!")
                print("       This means your credentials file is corrupted or invalid.")
              end
            end
            ffi.C.EVP_PKEY_free(verify_pkey)
          end
        end
      end

      -- Sign the decoded nonce with NKEY seed
      local sig = sign_nonce(nonce_bytes, creds.nkey_seed)
      if not sig then
        nats.error('failed to sign nonce')
      end

      -- Add JWT/NKEY auth to config
      config.jwt = creds.jwt
      config.sig = sig
      config.nkey = nkey
    elseif client.user ~= nil and client.pass ~= nil then
      -- Fall back to user/pass authentication
      config.user = client.user
      config.pass = client.pass
    end
  end


  -- Manual JSON encoding to avoid cjson bug
  local function json_escape(s)
    return s:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r')
  end

  local function to_json_bool(b)
    return b and 'true' or 'false'
  end

  local parts = {}
  table.insert(parts, '{"lang":"' .. json_escape(config.lang) .. '"')
  table.insert(parts, ',"version":"' .. json_escape(config.version) .. '"')
  table.insert(parts, ',"verbose":' .. to_json_bool(config.verbose))
  table.insert(parts, ',"pedantic":' .. to_json_bool(config.pedantic))
  table.insert(parts, ',"tls_required":' .. to_json_bool(config.tls_required))
  table.insert(parts, ',"protocol":1')  -- Support dynamic server reconfiguration

  if config.jwt then
    table.insert(parts, ',"jwt":"' .. json_escape(config.jwt) .. '"')
    table.insert(parts, ',"sig":"' .. json_escape(config.sig) .. '"')
    -- Try with nkey field included (even though it's in JWT)
    if config.nkey then
      table.insert(parts, ',"nkey":"' .. json_escape(config.nkey) .. '"')
    end
  elseif config.user then
    table.insert(parts, ',"user":"' .. json_escape(config.user) .. '"')
    table.insert(parts, ',"pass":"' .. json_escape(config.pass) .. '"')
  end

  table.insert(parts, '}')
  local connect_msg = table.concat(parts)

  if client.trace then
    print("DEBUG JSON length: " .. #connect_msg)
    print("DEBUG JSON first 200 chars: " .. connect_msg:sub(1, 200))
  end

  request.raw(client, 'CONNECT ' .. connect_msg .. '\r\n')

  -- Wait for server acknowledgment (+OK or -ERR)
  local ack = response.read(client)
  if ack.action == 'ERROR' then
    nats.error('CONNECT failed: server returned -ERR (Authorization Violation - check credentials)')
  elseif ack.action ~= 'OK' then
    nats.error('CONNECT failed: unexpected response: ' .. tostring(ack.action))
  end
end

function command.ping(client)
  request.raw(client, 'PING\r\n')

  -- wait for the server pong
  local data = response.read(client)
  if data.action == 'PONG' then
    return true
  else
    return false
  end
end

function command.pong(client)
  request.raw(client, 'PONG\r\n')
end

function command.request(client, subject, payload, callback)
  local inbox = create_inbox()
  local unique_id = uuid()
  client:subscribe(inbox, function(message, reply)
    client:unsubscribe(unique_id)
    callback(message, reply)
  end, unique_id)
  client:publish(subject, payload, inbox)
  return unique_id, inbox
end

function command.subscribe(client, subject, callback, unique_id)
  unique_id = unique_id or uuid()
  request.raw(client, 'SUB ' .. subject .. ' ' .. unique_id .. '\r\n')
  client.subscriptions[unique_id] = callback

  return unique_id
end

function command.unsubscribe(client, unique_id)
  request.raw(client, 'UNSUB ' .. unique_id .. '\r\n')
  client.subscriptions[unique_id] = nil
end

function command.publish(client, subject, payload, reply)
  if reply ~= nil then
    reply = ' ' .. reply
  else
    reply = ''
  end
  request.raw(client, {
    'PUB ' .. subject .. reply .. ' ' .. #payload .. '\r\n',
    payload .. '\r\n',
  })
end

function command.wait(client, quantity)
  quantity = quantity or 0

  local count = 0
  repeat
    local data = response.read(client)

    if data.action == 'PING' then
      command.pong(client)
    elseif data.action == 'MSG' then
      count = count + 1
      client.subscriptions[data.unique_id](data.content, data.reply)
    end
  until quantity > 0 and count >= quantity
end

-- Commands defined in this table do not take the precedence over
-- methods defined in the client prototype table.

nats.commands = {
  connect     = command.connect,
  ping        = command.ping,
  pong        = command.pong,
  request     = command.request,
  subscribe   = command.subscribe,
  unsubscribe = command.unsubscribe,
  publish     = command.publish,
  wait        = command.wait,
}

return nats
