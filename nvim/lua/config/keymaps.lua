
local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- <Leader>a
keymap.set('n', "<Leader>aa", "<cmd>@:<cr>", {desc="execute last command again" })

-- <Leader>b for buffer
keymap.set('n', "<Leader>bq", "<cmd>q<cr>", {desc="quit" })
keymap.set('n', "<Leader>bs", "<cmd>w<cr>", {desc="save" })
keymap.set('n', "<Leader>br", "<cmd>e!<cr>", {desc="reload" })
keymap.set('n', "<Leader>bd", "<cmd>BufferClose<cr>", {desc="close buffer" })
keymap.set({'n','v'}, "<Leader>b/", "<cmd>CommentToggle<CR>", {desc="toggle comment" })

-- <Leader>c
keymap.set('n', "<Leader>cs", "<cmd>SymbolsOutline<cr>", { desc = "Symbols Outline" })

-- <Leader>D
keymap.set('n', "<Leader>Dt", "<cmd>TroubleToggle<cr>", {desc="trouble" })
keymap.set('n', "<Leader>Dw", "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", {desc="workspace" })
keymap.set('n', "<Leader>Dd", "<cmd>TroubleToggle lsp_document_diagnostics<cr>", {desc= "document" })
keymap.set('n', "<Leader>Dq", "<cmd>TroubleToggle quickfix<cr>", {desc= "quickfix" })
keymap.set('n', "<Leader>Dl", "<cmd>TroubleToggle loclist<cr>", {desc= "loclist" })
keymap.set('n', "<Leader>Dr", "<cmd>TroubleToggle lsp_references<cr>", {desc= "references" })

-- <Leader>d
keymap.set('n', "<Leader>dd", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>", {desc= "show diagnostics" })
keymap.set('n', "<Leader>dc", "<cmd>lua require'dap'.continue()<cr>", {desc= "continue" })
keymap.set('n', "<Leader>db", ':lua require"dap".toggle_breakpoint()<CR>', {desc= "Toggle Breadpoint" })
keymap.set('n', "<Leader>dj", ':lua require"dap".step_over()<CR>', {desc= "step over" })
keymap.set('n', "<Leader>dk", ':lua require"dap".step_out()<CR>', {desc= "step out" })
keymap.set('n', "<Leader>dl", ':lua require"dap".step_into()<CR>', {desc= "step into" })
keymap.set('n', "<Leader>du", ':lua require"dap".up()<CR>', {desc= "up" })
keymap.set('n', "<Leader>d_", ':lua require"dap".disconnect();require"dap".stop();require"dap".run_last()<CR>', {desc= "disconnect" })
keymap.set('n', "<Leader>di", ':lua require"dap.ui.variables".visual_hover()<CR>', {desc= "visual_hover" })
keymap.set('n', "<Leader>ds", ':lua local widgets=require"dap.ui.widgets";widgets.centered_float(widgets.scopes)<CR>', {desc= "centered_float" })


-- <Leader>f
keymap.set('n', "<Leader>fm", "<cmd>lua require'utils'.open_md()<cr>", {desc= "open a markdown file in vscode" })
keymap.set('n', "<Leader>fs", "<cmd>w<cr>", {desc= "save file" })
keymap.set('n', "<Leader>ft", "<cmd>NvimTreeToggle<cr>", {desc= "toggle nvim tree" })
keymap.set('n', "<Leader>fr", "<cmd>RnvimrToggle<cr>", {desc= "toggle rnvimr" })
keymap.set('n', "<Leader>fy", "<cmd>lua require'utils'.yank_filepath()<cr>", {desc= "copy the file path" })
keymap.set('n', "<Leader>fd", "<cmd>lua require'utils'.yank_file_dir()<cr>", {desc= "copy the file path" })
keymap.set('n', "<Leader>fl", "<cmd>NvimTreeFindFile<CR>", {desc= "find file" })


-- <Leader>g
keymap.set('n', "<Leader>gj", "<cmd>lua require 'gitsigns'.next_hunk()<cr>", {desc= "Next Hunk" })
keymap.set('n', "<Leader>gk", "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", {desc= "Prev Hunk" })
keymap.set('n', "<Leader>gl", "<cmd>lua require 'gitsigns'.blame_line()<cr>", {desc= "Blame" })
keymap.set('n', "<Leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", {desc= "Preview Hunk" })
keymap.set('n', "<Leader>gr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", {desc= "Reset Hunk" })
keymap.set('n', "<Leader>gR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", {desc= "Reset Buffer" })
keymap.set('n', "<Leader>gs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", {desc= "Stage Hunk" })
keymap.set('n', "<Leader>gS", "<cmd>lua require 'gitsigns'.stage_buffer()<cr>", {desc= "Stage Buffer" })
keymap.set('n', "<Leader>gu", "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", {desc= "Undo Stage Hunk", })
keymap.set('n', "<Leader>go", "<cmd>Telescope git_status<cr>", {desc= "Open changed file" })
keymap.set('n', "<Leader>gb", "<cmd>Telescope git_branches<cr>", {desc= "Checkout branch" })
keymap.set('n', "<Leader>gc", "<cmd>Telescope git_commits<cr>", {desc= "Checkout commit" })
keymap.set('n', "<Leader>gC", "<cmd>Telescope git_bcommits<cr>", {desc= "Checkout commit(for current file)", })
keymap.set('n', "<Leader>gd", "<cmd>Gitsigns diffthis HEAD<cr>", {desc= "Git Diff", })

-- <Leader>h 
keymap.set('n', '<Leader>h', ':set hlsearch!<CR>', { noremap = true, silent = true }) -- no hl

-- <Leader>l for lsp
keymap.set('n', '<Leader>l', "", {desc="+Language"})
keymap.set({'n','v'}, '<Leader>la', "<cmd>lua vim.lsp.buf.code_action()<cr>", {desc="Code Action" })
--keymap.set('n', '<Leader>lA', "<cmd>Lspsaga range_code_action<cr>", {desc="Selected Action" })
keymap.set('n', '<Leader>ld', "<cmd>Telescope lsp_document_diagnostics<cr>", {desc="Document Diagnostics" })
keymap.set('n', '<Leader>lD', "<cmd>Telescope lsp_workspace_diagnostics<cr>", {desc="Workspace Diagnostics" })
keymap.set('n', '<Leader>lf', "<cmd>LspFormatting<cr>", {desc="Format" })
--keymap.set('n', '<Leader>lF', "<cmd>Lspsaga lsp_finder<cr>", {desc="LSP Finder" })
keymap.set('n', '<Leader>li', "<cmd>lua vim.lsp.buf.implementation()<cr>", {desc="implement" })
keymap.set('n', '<Leader>ll', "<cmd>lua vim.lsp.buf.hover()<cr>", {desc="hover" })
--keymap.set('n', '<Leader>lL', "<cmd>Lspsaga show_line_diagnostics<cr>", {desc="Line Diagnostics" })
keymap.set('n', '<Leader>lk', "<cmd>: LspRestart<cr>", {desc="restart lsp server" })
keymap.set('n', '<Leader>ln', "<cmd>lua vim.lsp.diagnostic.goto_next()<cr>", {desc="next diagnostic" })
keymap.set('n', '<Leader>lo', "<cmd>: SymbolsOutline<cr>", {desc="symbols outline" })
keymap.set('n', '<Leader>lp', "<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>", {desc="prev diagnostic" })
--keymap.set('n', '<Leader>lP', "<cmd>Lspsaga preview_definition<cr>", {desc="Preview Definition" })
keymap.set('n', '<Leader>lq', "<cmd>Telescope quickfix<cr>", {desc="Quickfix" })
keymap.set('n', '<Leader>lr', "<cmd>lua vim.lsp.buf.references()<cr>", {desc="references" })
keymap.set('n', '<leader>lR', "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename"  })
--keymap.set('n', '<Leader>lR', "<cmd>Lspsaga rename<cr>", {desc="Rename" })
keymap.set('n', '<Leader>lt', "<cmd>LspTypeDefinition<cr>", {desc="Type Definition" })
keymap.set('n', '<Leader>lx', "<cmd>cclose<cr>", {desc="Close Quickfix" })
keymap.set('n', '<Leader>ls', "<cmd>Telescope lsp_document_symbols<cr>", {desc="Document Symbols" })
keymap.set('n', '<Leader>lS', "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", {desc="Workspace Symbols" })
keymap.set('n', '<Leader>lz', "<cmd>LspInfo<cr>", {desc="Info" })
keymap.set('n', '<Leader>l,', "<cmd>LspInstallInfo<cr>", {desc="LSP servers" })

-- <Leader>q
keymap.set('n', "<Leader>qq", "<cmd>qall<cr>", {desc= "quit" })


-- <Leader>s
keymap.set('n', "<Leader>sb", "<cmd>Telescope git_branches<cr>", {desc= "Checkout branch" })
keymap.set('n', "<Leader>sc", "<cmd>:nohl<cr>", {desc= "no highlight" })
keymap.set('n', "<Leader>sd", "<cmd>Telescope lsp_document_diagnostics<cr>", {desc= "Document Diagnostics" })
keymap.set('n', "<Leader>sD", "<cmd>Telescope lsp_workspace_diagnostics<cr>", {desc= "Workspace Diagnostics" })
keymap.set('n', "<Leader>sf", "<cmd>Telescope find_files<CR><cr>", {desc= "Find File" })
keymap.set('n', "<Leader>sr", function() require("telescope.builtin").oldfiles({ cwd = vim.loop.cwd() }) end, {desc= "Old File" })
keymap.set('n', "<Leader>sm", "<cmd>Telescope marks<cr>", {desc= "Marks" })
keymap.set('n', "<Leader>sM", "<cmd>Telescope man_pages<cr>", {desc= "Man Pages" })
keymap.set('n', "<Leader>sR", "<cmd>Telescope registers<cr>", {desc= "Registers" })
keymap.set('n', "<Leader>st", "<cmd>Telescope live_grep<cr>", {desc= "Text" })
keymap.set('n', "<Leader>sT", "<cmd>Telescope live_grep<cr>", {desc= "Text" })
keymap.set('n', "<Leader>s,", "<cmd>FzfLua grep_cword<cr>", {desc= "Search word under cursor" })

-- <Leader>S
keymap.set('n', "<Leader>Ss", "<cmd>SessionSave<cr>", {desc= "Save Session" })
keymap.set('n', "<Leader>Sl", "<cmd>SessionLoad<cr>", {desc= "Load Session" })

-- <Leader>t
keymap.set('n', "<Leader>ta", "<cmd>TestSuite -v -cover<cr>", {desc= "TestSuite" })
keymap.set('n', "<Leader>tt", "<cmd>lua require('neotest').run.run() <cr>", {desc= "TestNearest" })
keymap.set('n', "<Leader>tf", '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>', {desc= "TestFile" })
keymap.set('n', "<Leader>tc", "<cmd>GoCover<cr>", {desc="go coverage" })
keymap.set('n', "<Leader>tC", "<cmd>GoCoverClear<cr>", {desc= "go coverage clear" })
keymap.set('n', "<Leader>tb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", {desc= "set break point" })
keymap.set('n', "<Leader>tr", "<cmd>lua require'dap'.continue()<cr>", {desc= "continue" })
keymap.set('n', "<Leader>zs", "<cmd>TZBottom<cr>", {desc="toggle status line" })
keymap.set('n', "<Leader>zt", "<cmd>TZTop<cr>", {desc= "toggle tab bar" })
keymap.set('n', "<Leader>zz", "<cmd>TZAtaraxis<cr>", {desc= "toggle zen" })

-- <Leader>;
keymap.set('n', '<Leader>;', ':Dashboard<CR>', { noremap = true, silent = true })

-- Ctrl
keymap.set('n', '<C-p>', ":Telescope find_files<CR>", { noremap = true, silent = true })
-- better window movement
keymap.set('n', '<C-h>', '<C-w>h', { silent = true })
keymap.set('n', '<C-j>', '<C-w>j', { silent = true })
keymap.set('n', '<C-k>', '<C-w>k', { silent = true })
keymap.set('n', '<C-l>', '<C-w>l', { silent = true })
-- resize with arrows
keymap.set('n', '<C-Up>', ':resize -2<CR>', { silent = true })
keymap.set('n', '<C-Down>', ':resize +2<CR>', { silent = true })
keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', { silent = true })
keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { silent = true })

keymap.set('n', '<C-q>', ':call QuickFixToggle()<CR>', { noremap = true, silent = true })


-- Other
-- better edit
keymap.set('n', 'Y', 'y$', {})
-- better indenting
keymap.set('v', '<', '<gv', { noremap = true, silent = true })
keymap.set('v', '>', '>gv', { noremap = true, silent = true })
-- I hate escape
keymap.set('i', 'jk', '<ESC>', { noremap = true, silent = true })
keymap.set('i', 'kj', '<ESC>', { noremap = true, silent = true })
keymap.set('i', 'jj', '<ESC>', { noremap = true, silent = true })
-- Tab switch buffer
keymap.set('n', '<TAB>', ':BufferNext<CR>', { noremap = true, silent = true })
keymap.set('n', '<S-TAB>', ':BufferPrevious<CR>', { noremap = true, silent = true })
-- Move selected line / block of text in visual mode
keymap.set('x', 'K', ':move \'<-2<CR>gv-gv', { noremap = true, silent = true })
keymap.set('x', 'J', ':move \'>+1<CR>gv-gv', { noremap = true, silent = true })

