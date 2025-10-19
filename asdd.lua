--local nats = dofile("./nats-nvim-cli.lua")
if nats == nil then
  nats = require("nats-nvim-cli")
end
-- nats.unsubscribe_all()

nats.publish("foo", "{\"asdf\": 288}")

local function subscribe_callback(payload)
  vim.notify('Received data: ' .. payload)
end


nats.subscribe("foo", subscribe_callback)
nats.subscribe("nvim.file.saved", subscribe_callback)

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.lua",
  callback = function()
    local file = vim.fn.expand("%:p")
    nats.publish("nvim.file.saved", vim.json.encode({
      file = file,
      filetype = vim.bo.filetype,
      lines = vim.api.nvim_buf_line_count(0)
    }))
  end
})


-- Example 7: Telescope integration (if you use Telescope)
function telescopeCalllback(response)
  if response then
    local topics = vim.json.decode(response)
    -- Create telescope picker with topics
    require('telescope.pickers').new({}, {
      prompt_title = "NATS Topics",
      finder = require('telescope.finders').new_table {
        results = topics
      },
      sorter = require('telescope.config').values.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        local actions = require('telescope.actions')
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = require('telescope.actions.state').get_selected_entry()
          --nats.subscribe(selection.value, handle_message)
          vim.notify("Subscribing to topic: " .. selection[1])
        end)
        return true
      end,
    }):find()
  end
end

nats.request("nvim.list_topics", "", telescopeCalllback)

telescopeCalllback("{\"test\": 22}")
