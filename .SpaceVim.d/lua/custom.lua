lcustom = {}
local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables

function lcustom.echo()
    print("hello lua")
end

function add_plugin()
   cmd 'packadd paq-nvim' 
   local paq = require('paq-nvim').paq
   paq{'savq/paq-nvim', opt = true}
   paq{'neovim/nvim-lspconfig'}
   paq{'nvim-treesitter/nvim-treesitter'}
   paq{'nvim-lua/completion-nvim'}
end

function llsp()
    local lspconfig = require('lspconfig')
    lspconfig.gopls.setup{on_attach=custom_attach}
    -- lspconfig.lua.setup{on_attach=custom_attach}
    vim.lsp.set_log_level("debug")
    lsp_key_map()
    print("init lsp finished")
end

function lcustom.init()
    vim.api.nvim_set_keymap('n','<Space>kk','<Cmd> lua lcustom.echo()<CR>',{ noremap = true, silent = true })
    vim.api.nvim_set_keymap('n','<Space>kl','<Cmd> lua llsp()<CR>',{ noremap = true, silent = true })
    add_plugin()
    llsp()
    -- g['deoplete#enable_at_startup'] = 1  -- enable deoplete at startup
    -- spc_key_bind('nore',{'g','d'}, 'test key bind', ':lua custom.echo()<CR>',1)
    -- vim.api.nvim_command('autocmd VimEnter * nnoremap gd :lua vim.lsp.buf.definition()<CR>')
    print('init llsp')
    -- vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    --
    vim.o['completeopt']='menuone,noinsert,noselect'

    treesitter()
    print('init finished')
end

function treesitter()
    require'nvim-treesitter.configs'.setup {
      ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
      highlight = {
        enable = true,              -- false will disable the whole extension
        disable = {},  -- list of language that will be disabled
      },
    }
end

function lsp_key_map()
   simple_key_map('<Space>gd','<Cmd>lua vim.lsp.buf.definition()<CR>') 
end

function simple_key_map(keys, cmd)
    vim.api.nvim_set_keymap('n',keys,cmd,{ noremap = true, silent = true })
end

custom_attach = function(client, bufnr)
	print("LSP started.");
	require'completion'.on_attach(client, bufnr)
	-- require'diagnostic'.on_attach(client)

	map('n','gD','<cmd>lua vim.lsp.buf.declaration()<CR>')
	map('n','gd','<cmd>lua vim.lsp.buf.definition()<CR>')
	map('n','K','<cmd>lua vim.lsp.buf.hover()<CR>')
	map('n','gr','<cmd>lua vim.lsp.buf.references()<CR>')
	map('n','gs','<cmd>lua vim.lsp.buf.signature_help()<CR>')
	map('n','gi','<cmd>lua vim.lsp.buf.implementation()<CR>')
	map('n','gt','<cmd>lua vim.lsp.buf.type_definition()<CR>')
	map('n','<leader>gw','<cmd>lua vim.lsp.buf.document_symbol()<CR>')
	map('n','<leader>gW','<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
	map('n','<leader>ah','<cmd>lua vim.lsp.buf.hover()<CR>')
	map('n','<leader>af','<cmd>lua vim.lsp.buf.code_action()<CR>')
	map('n','<leader>ee','<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>')
	map('n','<leader>ar','<cmd>lua vim.lsp.buf.rename()<CR>')
	map('n','<leader>=', '<cmd>lua vim.lsp.buf.formatting()<CR>')
	map('n','<leader>ai','<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
	map('n','<leader>ao','<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')
end

local map = function(type, key, value)
    -- autocmd VimEnter * nnoremap <Leader>[ :tabprev<CR> 
	-- local cmd = [[vim.fn.nvim_buf_set_keymap(0,type,key,value,{noremap = true, silent = true})]]
    -- vim.api.nvim_command('autocmd VimEnter * nnoremap '..key..' '..value)
	vim.fn.nvim_buf_set_keymap(0,type,key,value,{noremap = true, silent = true});
end

function _G.dump(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    print(unpack(objects))
end


local function RunIt(...)
    if pcall(function(...)
        string.format(...)
    end) == false then
       error("Function cannot format text",2)
    end
end

--[[
--// not work
spc_key_bind = function(nore, keys, desc, cmd, num)
   vim.fn['SpaceVim#custom#SPC'](nore, keys, desc, cmd, num) 
end
]]--

