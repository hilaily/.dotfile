local keymap = vim.keymap

-- <Leader>b for buffer
keymap.set("n", "<Leader>bq", "<cmd>q<cr>", { desc = "quit" })
keymap.set("n", "<Leader>bs", "<cmd>w<cr>", { desc = "save" })
keymap.set("n", "<Leader>br", "<cmd>e!<cr>", { desc = "reload" })
keymap.set("n", "<Leader>bd", "<cmd>BufferClose<cr>", { desc = "close buffer" })

-- <Leader>c
keymap.set("n", "<Leader>cs", "<cmd>SymbolsOutline<cr>", { desc = "Symbols Outline" })

-- <Leader>D for Trouble (v3 syntax)
keymap.set("n", "<Leader>Dt", "<cmd>Trouble diagnostics toggle<cr>", { desc = "trouble diagnostics" })
keymap.set("n", "<Leader>Dd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "document diagnostics" })
keymap.set("n", "<Leader>Dq", "<cmd>Trouble qflist toggle<cr>", { desc = "quickfix" })
keymap.set("n", "<Leader>Dl", "<cmd>Trouble loclist toggle<cr>", { desc = "loclist" })
keymap.set("n", "<Leader>Dr", "<cmd>Trouble lsp_references toggle<cr>", { desc = "references" })

-- <Leader>d for debug
keymap.set("n", "<Leader>dd", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "show diagnostics" })
keymap.set("n", "<Leader>dc", '<cmd>lua require("dap").continue()<cr>', { desc = "continue" })
keymap.set("n", "<Leader>db", '<cmd>lua require("dap").toggle_breakpoint()<cr>', { desc = "Toggle Breakpoint" })
keymap.set("n", "<Leader>dj", '<cmd>lua require("dap").step_over()<cr>', { desc = "step over" })
keymap.set("n", "<Leader>dk", '<cmd>lua require("dap").step_out()<cr>', { desc = "step out" })
keymap.set("n", "<Leader>dl", '<cmd>lua require("dap").step_into()<cr>', { desc = "step into" })
keymap.set("n", "<Leader>du", '<cmd>lua require("dap").up()<cr>', { desc = "up" })
keymap.set("n", "<Leader>d_", '<cmd>lua require("dap").disconnect();require("dap").stop();require("dap").run_last()<cr>', { desc = "disconnect" })
keymap.set("n", "<Leader>di", '<cmd>lua require("dap.ui.variables").visual_hover()<cr>', { desc = "visual hover" })
keymap.set("n", "<Leader>ds", '<cmd>lua local w=require("dap.ui.widgets");w.centered_float(w.scopes)<cr>', { desc = "scopes" })

-- <Leader>f
keymap.set("n", "<Leader>fm", "<cmd>lua require('utils').open_md()<cr>", { desc = "open markdown in external app" })
keymap.set("n", "<Leader>fs", "<cmd>w<cr>", { desc = "save file" })
keymap.set("n", "<Leader>ft", "<cmd>NvimTreeToggle<cr>", { desc = "toggle nvim tree" })
keymap.set("n", "<Leader>fy", "<cmd>lua require('utils').yank_filepath()<cr>", { desc = "copy file path" })
keymap.set("n", "<Leader>fd", "<cmd>lua require('utils').yank_file_dir()<cr>", { desc = "copy dir path" })
keymap.set("n", "<Leader>fl", "<cmd>NvimTreeFindFile<CR>", { desc = "find file in tree" })

-- <Leader>g
keymap.set("n", "<Leader>gj", "<cmd>lua require('gitsigns').next_hunk()<cr>", { desc = "Next Hunk" })
keymap.set("n", "<Leader>gk", "<cmd>lua require('gitsigns').prev_hunk()<cr>", { desc = "Prev Hunk" })
keymap.set("n", "<Leader>gl", "<cmd>lua require('gitsigns').blame_line()<cr>", { desc = "Blame" })
keymap.set("n", "<Leader>gp", "<cmd>lua require('gitsigns').preview_hunk()<cr>", { desc = "Preview Hunk" })
keymap.set("n", "<Leader>gr", "<cmd>lua require('gitsigns').reset_hunk()<cr>", { desc = "Reset Hunk" })
keymap.set("n", "<Leader>gR", "<cmd>lua require('gitsigns').reset_buffer()<cr>", { desc = "Reset Buffer" })
keymap.set("n", "<Leader>gs", "<cmd>lua require('gitsigns').stage_hunk()<cr>", { desc = "Stage Hunk" })
keymap.set("n", "<Leader>gS", "<cmd>lua require('gitsigns').stage_buffer()<cr>", { desc = "Stage Buffer" })
keymap.set("n", "<Leader>gu", "<cmd>lua require('gitsigns').undo_stage_hunk()<cr>", { desc = "Undo Stage Hunk" })
keymap.set("n", "<Leader>go", "<cmd>Telescope git_status<cr>", { desc = "Open changed file" })
keymap.set("n", "<Leader>gb", "<cmd>Telescope git_branches<cr>", { desc = "Checkout branch" })
keymap.set("n", "<Leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Checkout commit" })
keymap.set("n", "<Leader>gC", "<cmd>Telescope git_bcommits<cr>", { desc = "Checkout commit(for current file)" })
keymap.set("n", "<Leader>gd", "<cmd>Gitsigns diffthis HEAD<cr>", { desc = "Git Diff" })

-- <Leader>h
keymap.set("n", "<Leader>h", ":set hlsearch!<CR>", { noremap = true, silent = true, desc = "toggle hlsearch" })

-- <Leader>q
keymap.set("n", "<Leader>qq", "<cmd>qall<cr>", { desc = "quit all" })

-- <Leader>s for search
keymap.set("n", "<Leader>sb", "<cmd>Telescope git_branches<cr>", { desc = "Checkout branch" })
keymap.set("n", "<Leader>sc", "<cmd>nohl<cr>", { desc = "no highlight" })
keymap.set("n", "<Leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "Document Diagnostics" })
keymap.set("n", "<Leader>sD", "<cmd>Telescope diagnostics<cr>", { desc = "Workspace Diagnostics" })
keymap.set("n", "<Leader>sf", "<cmd>Telescope find_files<cr>", { desc = "Find File" })
keymap.set("n", "<Leader>sr", function()
	require("telescope.builtin").oldfiles({ cwd = vim.uv.cwd() })
end, { desc = "Old File" })
keymap.set("n", "<Leader>sm", "<cmd>Telescope marks<cr>", { desc = "Marks" })
keymap.set("n", "<Leader>sM", "<cmd>Telescope man_pages<cr>", { desc = "Man Pages" })
keymap.set("n", "<Leader>sR", "<cmd>Telescope registers<cr>", { desc = "Registers" })
keymap.set("n", "<Leader>st", "<cmd>Telescope live_grep<cr>", { desc = "Text" })
keymap.set("n", "<Leader>s,", function()
	local ok, fzf_lua = pcall(require, "fzf-lua")
	if ok then
		fzf_lua.grep_cword()
	else
		require("telescope.builtin").grep_string({ word_match = "-w" })
	end
end, { desc = "Search word under cursor" })

-- <Leader>t for test
keymap.set("n", "<Leader>tt", '<cmd>lua require("neotest").run.run()<cr>', { desc = "TestNearest" })
keymap.set("n", "<Leader>tf", '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>', { desc = "TestFile" })
keymap.set("n", "<Leader>tc", "<cmd>GoCover<cr>", { desc = "go coverage" })
keymap.set("n", "<Leader>tC", "<cmd>GoCoverClear<cr>", { desc = "go coverage clear" })
keymap.set("n", "<Leader>tb", '<cmd>lua require("dap").toggle_breakpoint()<cr>', { desc = "set break point" })
keymap.set("n", "<Leader>tr", '<cmd>lua require("dap").continue()<cr>', { desc = "continue" })

-- <Leader>;
keymap.set("n", "<Leader>;", "<cmd>Dashboard<CR>", { noremap = true, silent = true, desc = "Dashboard" })

-- Ctrl-p: find files with recent-first boost
keymap.set("n", "<C-p>", function()
	local builtin = require("telescope.builtin")
	local recent_paths = {}
	for _, file in ipairs(vim.v.oldfiles) do
		if vim.fn.filereadable(file) == 1 then
			local abs_path = vim.fn.fnamemodify(file, ":p")
			local rel_path = vim.fn.fnamemodify(file, ":.")
			recent_paths[abs_path] = true
			recent_paths[rel_path] = true
			recent_paths[vim.fn.fnamemodify(file, ":t")] = true
		end
	end
	local ok, _ = pcall(require, "telescope._extensions.fzf")
	if ok then
		builtin.find_files({ hidden = true, no_ignore = false })
	else
		local sorters = require("telescope.sorters")
		builtin.find_files({
			hidden = true,
			no_ignore = false,
			sorter = sorters.Sorter:new({
				discard = true,
				scoring_function = function(_, prompt, line, entry)
					local score = 0
					local path = entry.path or entry.value or line
					local abs_path = vim.fn.fnamemodify(path, ":p")
					local rel_path = vim.fn.fnamemodify(path, ":.")
					local filename = vim.fn.fnamemodify(path, ":t")
					if recent_paths[abs_path] or recent_paths[rel_path] or recent_paths[filename] then
						score = 1000
					end
					if prompt and prompt ~= "" then
						if path:lower():find(prompt:lower(), 1, true) then
							score = score + 100
						end
					end
					return score
				end,
			}),
		})
	end
end, { noremap = true, silent = true, desc = "Find Files (Recent First)" })

-- Window movement
keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
keymap.set("n", "<C-l>", "<C-w>l", { silent = true })

-- Resize with arrows
keymap.set("n", "<C-Up>", ":resize -2<CR>", { silent = true })
keymap.set("n", "<C-Down>", ":resize +2<CR>", { silent = true })
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { silent = true })
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { silent = true })

-- Quickfix toggle
keymap.set("n", "<C-q>", function()
	for _, win in pairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			vim.cmd("cclose")
			return
		end
	end
	vim.cmd("copen")
end, { noremap = true, silent = true, desc = "Toggle Quickfix" })

-- Two spaces → live_grep
keymap.set("n", "  ", function()
	require("telescope.builtin").live_grep()
end, { noremap = true, silent = true, desc = "Search in Files" })

-- Misc
keymap.set("n", "Y", "y$", {})
keymap.set("v", "<", "<gv", { noremap = true, silent = true })
keymap.set("v", ">", ">gv", { noremap = true, silent = true })
keymap.set("i", "jk", "<ESC>", { noremap = true, silent = true })
keymap.set("i", "kj", "<ESC>", { noremap = true, silent = true })
keymap.set("i", "jj", "<ESC>", { noremap = true, silent = true })

-- Tab switch buffer (barbar)
keymap.set("n", "<TAB>", "<cmd>BufferNext<CR>", { noremap = true, silent = true })
keymap.set("n", "<S-TAB>", "<cmd>BufferPrevious<CR>", { noremap = true, silent = true })

-- Move selected line / block in visual mode
keymap.set("x", "K", ":move '<-2<CR>gv-gv", { noremap = true, silent = true })
keymap.set("x", "J", ":move '>+1<CR>gv-gv", { noremap = true, silent = true })
