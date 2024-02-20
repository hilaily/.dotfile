-- LSP
require 'lspconfig'.gopls.setup {
  -- cmd = {DATA_PATH .. "/lspinstall/go/gopls"},
  cmd = { "gopls", "serve" }, -- use cmd in path, I can update it easily
  settings = {
    gopls = {
      analyses = {
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      staticcheck = false
    }
  },
  root_dir = require 'lspconfig'.util.root_pattern(".git", "go.mod", "go.work"),
  init_options = { usePlaceholders = true, completeUnimported = true },
  on_attach = require 'lsp'.common_on_attach
}

--[[
require'dap-install'.config("go_delve",{})

-- DAP
local dap = require "dap"
vim.fn.sign_define('DapBreakpoint', {text='🟥', texthl='', linehl='', numhl=''})
--vim.fn.sign_define('DapStopped', {text='⭐️', texthl='', linehl='', numhl=''})

local M = {}

local ts_utils = require 'nvim-treesitter.ts_utils'

function M.get_node()
  local n = ts_utils.get_node_at_cursor()
  put(ts_utils.get_node_text(n))
end

function M.get_node2()
    local current_node = ts_utils.get_node_at_cursor()
    if not current_node then
        return ""
    end

    local expr = current_node

    while expr do
        if expr:type() == 'function_definition' then
            put(expr:type())
            break
        end
        expr = expr:parent()
    end

    if not expr then return "" end

    put(ts_utils.get_node_text(expr))
    return (ts_utils.get_node_text(expr:child(1)))[1]
end

return M

--[[
-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
    {
        type = "go",
        name = "Debug",
        request = "launch",
        program = "${file}"
    },
    -- works with go.mod packages and sub packagesfunction M.get_current_function_name() local current_node = ts_utils.get_node_at_cursor() if not current_node then return "" end

local expr = current_node

while expr do
    if expr:type() == 'function_definition' then
        break
    end
    expr = expr:parent()
end

if not expr then return "" end

return (ts_utils.get_node_text(expr:child(1)))[1]
end 
    {
        type = "go",
        name = "Debug test (go.mod)",
        request = "launch",
        mode = "test",
        program = "./${relativeFileDirname}"
    } 
}


--[[
local dap = require('dap')

dap.adapters.go = function(callback, config)
    local stdout = vim.loop.new_pipe(false)
    local handle
    local pid_or_err
    local port = 38697
    local opts = {
      stdio = {nil, stdout},
      args = {"dap", "-l", "127.0.0.1:" .. port},
      detached = true
    }
    handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
      stdout:close()
      handle:close()
      if code ~= 0 then
        print('dlv exited with code', code)
      end
    end)
    assert(handle, 'Error running dlv: ' .. tostring(pid_or_err))
    stdout:read_start(function(err, chunk)
      assert(not err, err)
      if chunk then
        vim.schedule(function()
          require('dap.repl').append(chunk)
        end)
      end
    end)
    -- Wait for delve to start
    vim.defer_fn(
      function()
        callback({type = "server", host = "127.0.0.1", port = port})
      end,
      100)
  end
  -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
  dap.configurations.go = {
    {
      type = "go",
      name = "Debug",
      request = "launch",
      program = "${file}"
    },
    {
      type = "go",
      name = "Debug test", -- configuration for debugging test files
      request = "launch",
      mode = "test",
      program = "${file}"
    },
    -- works with go.mod packages and sub packages 
    {
      type = "go",
      name = "Debug test (go.mod)",
      request = "launch",
      mode = "test",
      program = "./${relativeFileDirname}"
    } 
}
]]
