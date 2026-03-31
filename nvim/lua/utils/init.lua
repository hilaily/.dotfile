local M = {}

function M.yank_filepath()
	local p = vim.fn.expand("%:p")
	local line = vim.fn.line(".")
	p = p .. ":" .. line
	print(p)
	vim.fn.setreg("+", p)
end

function M.yank_file_dir()
	local p = vim.fn.expand("%:p:h")
	print(p)
	vim.fn.setreg("+", p)
end

function M.open_md()
	local p = vim.fn.expand("%:p")
	vim.fn.system("open -a marktext " .. p)
end

function M.file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	end
	return false
end

return M
