lcustom = {}

function lcustom.echo()
    print("hello lua")
end

function llsp()
    local lspconfig = require('lspconfig')
    lspconfig.gopls.setup{}
    vim.lsp.set_log_level("debug")
    lsp_key_map()
    print("init lsp finished")

end

function lcustom.init()
    vim.api.nvim_set_keymap('n','<Space>kk','<Cmd> lua lcustom.echo()<CR>',{ noremap = true, silent = true })
    vim.api.nvim_set_keymap('n','<Space>kl','<Cmd> lua llsp()<CR>',{ noremap = true, silent = true })
    -- spc_key_bind('nore',{'k','k'}, 'test key bind', ':lua custom.echo()<CR>',1)
    llsp()
end

function lsp_key_map()
   simple_key_map('<Space>gd','<Cmd>lua vim.lsp.buf.definition()<CR>') 
end

function simple_key_map(keys, cmd)
    vim.api.nvim_set_keymap('n',keys,cmd,{ noremap = true, silent = true })
end



--[[
--// not work
spc_key_bind = function(nore, keys, desc, cmd, num)
   vim.fn['SpaceVim#custom#SPC'](nore, keys, desc, cmd, num) 
end
]]--

