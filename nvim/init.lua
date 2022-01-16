CONFIG_PATH = vim.fn.stdpath('config')
DATA_PATH = vim.fn.stdpath('data')
CACHE_PATH = vim.fn.stdpath('cache')
P = vim.inspect

require('lv-globals')
vim.cmd('luafile '..CONFIG_PATH..'/settings.lua')
require('settings')
require('plugins')
require('utils')
require('pluginconfig')
require('autocommands')
require('keymappings')
require('colorscheme') -- This plugin must be required somewhere after nvimtree. Placing it before will break navigation keymappings

-- TODO is there a way to do this without vimscript
vim.cmd('source '..CONFIG_PATH..'/vimscript/functions.vim')

-- LSP
require('lsp')

--[[
require('lsp.css-ls')
require('lsp.docker-ls')
require('lsp.emmet-ls')
require('lsp.html-ls')
require('lsp.json-ls')
require('lsp.latex-ls')
require('lsp.python-ls')
require('lsp.rust-ls')
require('lsp.yaml-ls')
]]

