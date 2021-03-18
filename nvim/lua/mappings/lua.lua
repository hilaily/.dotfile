local function map(mode, lhs, rhs, opts)
    local options = {noremap = true}
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- keybind list
map("", "<leader>c", '"+y')

-- open terminals  
map("n", "<C-b>" , [[<Cmd> vnew term://bash<CR>]] , opt) -- split term vertically , over the right  
map("n", "<C-x>" , [[<Cmd> split term://bash | resize 10 <CR>]] , opt) -- split term vertically , over the right  
-- file
map("n","<leader>fs",[[<Cmd> w<CR>]])

-- buffer
map("n", "<leader>bn",[[<Cmd> bnext<CR>]])
map("n", "<leader>bp",[[<Cmd> bprev<CR>]])
map("n", "<leader>bd",[[<Cmd> w\|bd<cr><CR>]])

-- window
map("n", "<C-h>",[[<C-w>h<CR>]])
map("n", "<C-l>",[[<C-w>l<CR>]])
map("n", "<C-k>",[[<C-w>k<CR>]])
map("n", "<C-j>",[[<C-w>j<CR>]])

-- search
map("n","<leader>sc",[[<Cmd> nohlsearch<CR>]])

-- vim self
map("n","<leader>qq",[[<Cmd> qa<CR>]])
map("n","<leader>qr",[[<Cmd> luafile $MYVIMRC<CR>]])

