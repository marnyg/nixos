for k, _ in pairs(package.loaded) do
	if string.match(k, "^my") then
		print(k)
		package.loaded[k] = nil
	end
end

function Dump(o)
	if type(o) == "table" then
		local s = "{ \n"
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. Dump(v) .. ","
		end
		return s .. "} \n"
	else
		return tostring(o)
	end
end

function P(o)
	print(Dump(o))
end

vim.g.loaded_gzip = false
vim.g.loaded_matchit = false
vim.g.loaded_netrwPlugin = false
vim.g.loaded_tarPlugin = false
vim.g.loaded_zipPlugin = false
vim.g.loaded_man = false
vim.g.loaded_2html_plugin = false
vim.g.loaded_remote_plugins = false

--require("my.options")
--require("my.plugins")
--require("my.keybinds")
