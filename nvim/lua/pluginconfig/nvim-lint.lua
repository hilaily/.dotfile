local lint_lib  = require('lint')

lint_lib.linters_by_ft = {
	go = {'golangcilint'}
}

local golangcilint = lint_lib.linters.golangcilint
golangcilint.args = {
    'run',
	'--config',
	'~/.dotfile/.golangci_strict.yml',
    '--out-format',
    'json',
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
callback = function()
	require("lint").try_lint()
end,
})