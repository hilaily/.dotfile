if vim.loader then
	vim.loader.enable()
end

-- 让 Mason / 健康检查能找到本仓库常用的本地 CLI（fd、lazygit、tree-sitter 等）
local _local_bin = vim.fn.expand("~/.local/bin")
if vim.fn.isdirectory(_local_bin) == 1 then
	vim.env.PATH = _local_bin .. ":" .. vim.env.PATH
end
-- 全局 npm 包（如 mermaid-cli 的 `mmdc`）通常在 $(npm prefix -g)/bin
do
	local ok, out = pcall(vim.fn.system, { "npm", "prefix", "-g" })
	if ok and out and out ~= "" then
		local npm_bin = vim.fn.trim(out) .. "/bin"
		if vim.fn.isdirectory(npm_bin) == 1 then
			vim.env.PATH = npm_bin .. ":" .. vim.env.PATH
		end
	end
end

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

_G.dd = function(...)
	require("utils.debug").dump(...)
end
vim.print = _G.dd

require("config.lazy")


-- CONFIG_PATH = vim.fn.stdpath('config')
-- DATA_PATH = vim.fn.stdpath('data')
-- CACHE_PATH = vim.fn.stdpath('cache')
-- P = vim.inspect

-- require('lv-globals')
-- vim.cmd('luafile '..CONFIG_PATH..'/settings.lua')
-- require('settings')
-- require('plugins')
-- require('utils')
-- require('pluginconfig')
-- require('autocommands')
-- require('keymappings')
-- require('colorscheme') -- This plugin must be required somewhere after nvimtree. Placing it before will break navigation keymappings

-- -- TODO is there a way to do this without vimscript
-- vim.cmd('source '..CONFIG_PATH..'/vimscript/functions.vim')

-- -- LSP
-- require('lsp')

