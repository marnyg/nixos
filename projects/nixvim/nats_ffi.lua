-- ~/.config/nvim/lua/nats_ffi.lua
local ffi = require("ffi")

-- Define the C structs and functions we need
ffi.cdef[[
    // Status codes
    typedef enum {
        NATS_OK = 0,
        NATS_ERR = 1,
        // ... other status codes
    } natsStatus;

    // Opaque types
    typedef struct __natsConnection natsConnection;
    typedef struct __natsSubscription natsSubscription;
    typedef struct __natsMsg natsMsg;
    typedef struct __natsOptions natsOptions;

    // Message handler callback type
    typedef void (*natsMsgHandler)(natsConnection *nc, natsSubscription *sub, natsMsg *msg, void *closure);

    // Core functions
    natsStatus natsConnection_Connect(natsConnection **nc, natsOptions *options);
    natsStatus natsConnection_ConnectTo(natsConnection **nc, const char *url);
    natsStatus natsConnection_Flush(natsConnection *nc);
    natsStatus natsConnection_FlushTimeout(natsConnection *nc, int64_t timeout);
    void natsConnection_Destroy(natsConnection *nc);
    
    // Options
    natsStatus natsOptions_Create(natsOptions **opts);
    natsStatus natsOptions_SetURL(natsOptions *opts, const char *url);
    void natsOptions_Destroy(natsOptions *opts);

    // Authentication functions
    natsStatus natsOptions_SetUserInfo(natsOptions *opts, const char *user, const char *password);
    natsStatus natsOptions_SetToken(natsOptions *opts, const char *token);
    natsStatus natsOptions_SetUserCredentialsFromFiles(natsOptions *opts, const char *userOrChainedFile, const char *seedFile);
    natsStatus natsOptions_SetUserCredentialsFromMemory(natsOptions *opts, const char *jwtAndSeedContent);
    
    // Publishing
    natsStatus natsConnection_PublishString(natsConnection *nc, const char *subject, const char *str);
    natsStatus natsConnection_Publish(natsConnection *nc, const char *subject, const void *data, int dataLen);
    
    // Subscribing
    natsStatus natsConnection_Subscribe(natsSubscription **sub, natsConnection *nc, 
                                        const char *subject, natsMsgHandler cb, void *cbClosure);
    natsStatus natsConnection_SubscribeSync(natsSubscription **sub, natsConnection *nc, const char *subject);
    natsStatus natsSubscription_NextMsg(natsMsg **msg, natsSubscription *sub, int64_t timeout);
    natsStatus natsSubscription_Unsubscribe(natsSubscription *sub);
    void natsSubscription_Destroy(natsSubscription *sub);
    
    // Message functions
    const char* natsMsg_GetSubject(const natsMsg *msg);
    const char* natsMsg_GetData(const natsMsg *msg);
    int natsMsg_GetDataLength(const natsMsg *msg);
    void natsMsg_Destroy(natsMsg *msg);
    
    // Error handling
    const char* natsStatus_GetText(natsStatus s);
    
    // Library management
    natsStatus nats_Open(int64_t lockSpinCount);
    void nats_Close();
]]

-- Load the NATS C library
-- Try to use the Nix-provided path if available, otherwise fall back to system search
local nats
if vim and vim.g and vim.g.nats_library_path then
    nats = ffi.load(vim.g.nats_library_path)
else
    -- Fallback for non-Nix environments or direct Lua usage
    nats = ffi.load("nats")
end

-- Initialize the library
nats.nats_Open(-1)

local M = {}

-- Helper to check status
local function check_status(status, operation)
    if status ~= nats.NATS_OK then
        local err_text = ffi.string(nats.natsStatus_GetText(status))
        error(string.format("%s failed: %s (status code: %d)", operation, err_text, tonumber(status)))
    end
end

-- Helper to check if a file exists
local function file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- Create a connection class
M.Connection = {}
M.Connection.__index = M.Connection

-- Create a new NATS connection
-- @param url The NATS server URL (e.g., "nats://localhost:4222")
-- @param auth Optional authentication. Can be:
--   - string: path to .creds file
--   - table with 'file': path to .creds file
--   - table with 'user' and 'password': username/password auth
--   - table with 'token': token auth
--   - table with 'jwt_and_seed': embedded JWT and seed content
function M.Connection:new(url, auth)
    local self = setmetatable({}, M.Connection)

    -- Create options
    local opts = ffi.new("natsOptions*[1]")
    check_status(nats.natsOptions_Create(opts), "natsOptions_Create")

    if url then
        check_status(nats.natsOptions_SetURL(opts[0], url), "natsOptions_SetURL")
    end

    -- Handle authentication
    if auth then
        if type(auth) == "string" then
            -- Assume it's a credentials file path
            -- Expand ~ to home directory if present
            local creds_path = auth
            if creds_path:sub(1, 1) == "~" then
                local home = os.getenv("HOME") or os.getenv("USERPROFILE")
                if home then
                    creds_path = home .. creds_path:sub(2)
                end
            end

            -- Check if file exists
            if not file_exists(creds_path) then
                error(string.format("Credentials file not found: %s", creds_path))
            end

            -- Pass NULL as second parameter for chained credentials file
            local null_ptr = ffi.cast("const char*", nil)
            check_status(
                nats.natsOptions_SetUserCredentialsFromFiles(opts[0], creds_path, null_ptr),
                "natsOptions_SetUserCredentialsFromFiles"
            )
        elseif type(auth) == "table" then
            if auth.file then
                -- Credentials from file
                -- Expand ~ to home directory if present
                local creds_path = auth.file
                if creds_path:sub(1, 1) == "~" then
                    local home = os.getenv("HOME") or os.getenv("USERPROFILE")
                    if home then
                        creds_path = home .. creds_path:sub(2)
                    end
                end
                local seed_path = auth.seed_file
                if seed_path and seed_path:sub(1, 1) == "~" then
                    local home = os.getenv("HOME") or os.getenv("USERPROFILE")
                    if home then
                        seed_path = home .. seed_path:sub(2)
                    end
                end

                -- Check if files exist
                if not file_exists(creds_path) then
                    error(string.format("Credentials file not found: %s", creds_path))
                end
                if seed_path and not file_exists(seed_path) then
                    error(string.format("Seed file not found: %s", seed_path))
                end

                -- Convert nil to NULL pointer for FFI
                local seed_ptr = seed_path and seed_path or ffi.cast("const char*", nil)
                check_status(
                    nats.natsOptions_SetUserCredentialsFromFiles(opts[0], creds_path, seed_ptr),
                    "natsOptions_SetUserCredentialsFromFiles"
                )
            elseif auth.user and auth.password then
                -- Username/password authentication
                check_status(
                    nats.natsOptions_SetUserInfo(opts[0], auth.user, auth.password),
                    "natsOptions_SetUserInfo"
                )
            elseif auth.token then
                -- Token authentication
                check_status(
                    nats.natsOptions_SetToken(opts[0], auth.token),
                    "natsOptions_SetToken"
                )
            elseif auth.jwt_and_seed then
                -- Embedded JWT and seed
                check_status(
                    nats.natsOptions_SetUserCredentialsFromMemory(opts[0], auth.jwt_and_seed),
                    "natsOptions_SetUserCredentialsFromMemory"
                )
            else
                error("Invalid authentication table. Must contain 'file', 'user'/'password', 'token', or 'jwt_and_seed'")
            end
        end
    end

    -- Connect
    local nc = ffi.new("natsConnection*[1]")
    check_status(nats.natsConnection_Connect(nc, opts[0]), "natsConnection_Connect")

    -- Clean up options
    nats.natsOptions_Destroy(opts[0])

    self.nc = nc[0]
    return self
end

function M.Connection:publish(subject, data)
    check_status(nats.natsConnection_PublishString(self.nc, subject, data), "Publish")
end

function M.Connection:subscribe_sync(subject)
    local sub = ffi.new("natsSubscription*[1]")
    check_status(nats.natsConnection_SubscribeSync(sub, self.nc, subject), "SubscribeSync")
    return M.Subscription:new(sub[0])
end

function M.Connection:close()
    if self.nc then
        -- Flush any pending messages before closing (ignore errors)
        pcall(function()
            nats.natsConnection_FlushTimeout(self.nc, 1000) -- 1 second timeout
        end)
        nats.natsConnection_Destroy(self.nc)
        self.nc = nil
    end
end

-- Subscription class
M.Subscription = {}
M.Subscription.__index = M.Subscription

function M.Subscription:new(sub)
    local self = setmetatable({}, M.Subscription)
    self.sub = sub
    return self
end

function M.Subscription:next_msg(timeout_ms)
    local msg = ffi.new("natsMsg*[1]")
    local status = nats.natsSubscription_NextMsg(msg, self.sub, timeout_ms or 1000)
    
    if status ~= nats.NATS_OK then
        return nil  -- Timeout or error
    end
    
    local subject = ffi.string(nats.natsMsg_GetSubject(msg[0]))
    local data = ffi.string(nats.natsMsg_GetData(msg[0]), nats.natsMsg_GetDataLength(msg[0]))
    
    nats.natsMsg_Destroy(msg[0])
    
    return {subject = subject, data = data}
end

function M.Subscription:unsubscribe()
    if self.sub then
        nats.natsSubscription_Unsubscribe(self.sub)
        nats.natsSubscription_Destroy(self.sub)
        self.sub = nil
    end
end

return M
