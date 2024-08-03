vim.g.autoformat = true

vim.cmd("set iskeyword+=-") -- treat dash separated words as a word text object"
vim.cmd("set shortmess+=c") -- Don't pass messages to |ins-completion-menu|.
vim.cmd("set inccommand=split") -- Make substitution work in realtime
vim.opt.hidden = true -- Required to keep multiple buffers open multiple buffers
vim.opt.title = true
TERMINAL = vim.fn.expand("$TERMINAL")
vim.cmd('let &titleold="' .. TERMINAL .. '"')
vim.opt.titlestring = "%<%F%=%l/%L - nvim"
vim.wo.wrap = true -- Display long lines as just one line
vim.cmd("set whichwrap+=<,>,[,],h,l") -- move to next line with theses keys
vim.cmd("syntax on") -- syntax highlighting
vim.opt.pumheight = 10 -- Makes popup menu smaller
vim.opt.fileencoding = "utf-8" -- The encoding written to file
vim.opt.cmdheight = 2 -- More space for displaying messages
vim.cmd("set colorcolumn=99999") -- fix indentline for now
vim.opt.mouse = "a" -- Enable your mouse
vim.opt.splitbelow = true -- Horizontal splits will automatically be below
vim.opt.termguicolors = true -- set term gui colors most terminals support this
vim.opt.splitright = true -- Vertical splits will automatically be to the right
-- vim.opt.t_Co = "256" -- Support 256 colors
vim.opt.conceallevel = 0 -- So that I can see `` in markdown files
vim.o.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.bo.smartindent = true -- Makes indenting smart
vim.wo.number = true -- set numbered lines
vim.wo.relativenumber = true -- set relative number
vim.wo.cursorline = true -- Enable highlighting of the current line
vim.opt.showtabline = 2 -- Always show tabs
vim.opt.showmode = false -- We don't need to see things like -- INSERT -- anymore
vim.opt.backup = false -- This is recommended by coc
vim.opt.writebackup = false -- This is recommended by coc
vim.wo.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
vim.opt.updatetime = 300 -- Faster completion
vim.opt.timeoutlen = 500 -- By default timeoutlen is 1000 ms
vim.opt.clipboard = "unnamedplus" -- Copy paste between vim and everything else
vim.cmd("filetype plugin on") -- filetype detection
-- vim.opt.guifont = "JetBrainsMono\\ Nerd\\ Font\\ Mono:h18"
-- vim.opt.guifont = "Hack\\ Nerd\\ Font\\ Mono"
-- vim.opt.guifont = "SauceCodePro Nerd Font:h17"
vim.opt.guifont = "FiraCode Nerd Font:h17"

-- vim.opt.guifont = "JetBrains\\ Mono\\ Regular\\ Nerd\\ Font\\ Complete"
vim.g.vim_markdown_folding_disabled = 1

vim.g.vimspector_enable_mappings = "HUMAN"
vim.g["test#go#rspec#options"] = { nearest = "--v", suite = "--v" }

-- git blame
vim.cmd("highlight default link gitblame SpecialComment")
vim.g.gitblame_enabled = 0

-- last position jump
vim.cmd([[
autocmd BufReadPost *  if line("'\"") >= 1 && line("'\"") <= line("$") | exe "normal! g`\"" |  endif
]])

-- vim.cmd('let g:nvcode_termcolors=256')
-- --local cc = 'gruvbox'
-- local cc = 'lunar'
-- vim.opt.background="dark"
-- vim.cmd('colorscheme ' .. cc)
