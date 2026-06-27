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

--- 无写权限时用 sudo 保存当前文件（对应 :W）
function M.sudo_write()
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		vim.notify("W: 当前 buffer 没有文件名", vim.log.levels.ERROR)
		return
	end

	local ok, err = pcall(function()
		vim.cmd("write !sudo tee % > /dev/null")
		vim.cmd("edit!")
	end)
	if not ok then
		local msg = vim.split(tostring(err), "\n", { plain = true })[1]
		vim.notify("W: 保存失败 — " .. msg, vim.log.levels.ERROR)
		return
	end

	vim.notify("W: 已保存 " .. name, vim.log.levels.INFO)
end

return M
