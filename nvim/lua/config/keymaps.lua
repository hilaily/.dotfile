
local opts = {
    mode = "n", -- NORMAL mode
    prefix = "<leader>",
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = false -- use `nowait` when creating keymaps
}





local mappings = {
    -- ["/"] = "Comment",
    -- ["c"] = "Close Buffer",
    ["e"] = "Explorer",
    -- ["f"] = "Find File",
    ["h"] = "No Highlight",
    a = {
        name = "+Action",
        a = { "<cmd>@:<cr>", "execute last command again" }
    },
    b = {
        name = "+Buffer",
        n = { "<cmd>BufferNext<cr>", "next buffer" },
        p = { "<cmd>BufferPrevious<cr>", "previous buffer" },
        q = { "<cmd>q<cr>", "quit" },
        s = { "<cmd>w<cr>", "save" },
        r = { "<cmd>e!<cr>", "reload" },
        d = { "<cmd>BufferClose<cr>", "close buffer" },
        z = { "<cmd>CommentToggle<CR>", "toggle comment" },
    },
    D = {
        name = "+Diagnostics",
        t = { "<cmd>TroubleToggle<cr>", "trouble" },
        w = { "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", "workspace" },
        d = { "<cmd>TroubleToggle lsp_document_diagnostics<cr>", "document" },
        q = { "<cmd>TroubleToggle quickfix<cr>", "quickfix" },
        l = { "<cmd>TroubleToggle loclist<cr>", "loclist" },
        r = { "<cmd>TroubleToggle lsp_references<cr>", "references" },
    },
    d = {
        name = "+Debug",
        -- b = {"<cmd>DebugToggleBreakpoint<cr>", "Toggle Breakpoint"},
        -- c = {"<cmd>DebugContinue<cr>", "Continue"},
        -- i = {"<cmd>DebugStepInto<cr>", "Step Into"},
        -- o = {"<cmd>DebugStepOver<cr>", "Step Over"},
        -- r = {"<cmd>DebugToggleRepl<cr>", "Toggle Repl"},
        -- s = {"<cmd>DebugStart<cr>", "Start"}
        d = { "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>", "show diagnostics" },

        c = { "<cmd>lua require'dap'.continue()<cr>", "continue" },
        b = { ':lua require"dap".toggle_breakpoint()<CR>', "Toggle Breadpoint" },
        j = { ':lua require"dap".step_over()<CR>', "step over" },
        k = { ':lua require"dap".step_out()<CR>', "step out" },
        l = { ':lua require"dap".step_into()<CR>', "step into" },
        --<c-h>', ':lua require"dap".continue()<CR>')
        u = { ':lua require"dap".up()<CR>', "up" },
        -- d = {':lua require"dap".down()<CR>', "down"},
        _ = { ':lua require"dap".disconnect();require"dap".stop();require"dap".run_last()<CR>', "disconnect" },
        --r = {':lua require"dap".repl.open({}, "vsplit")<CR><C-w>l', "repl open"},
        i = { ':lua require"dap.ui.variables".visual_hover()<CR>', "visual_hover" },
        --? = {':lua require"dap.ui.variables".scopes()<CR>',"scopes"},
        -- e = {':lua require"dap".set_exception_breakpoints({"all"})<CR>',"esception bp"},
        -- a = {':lua require"debugHelper".attach()<CR>',"attach"},
        -- A = {':lua require"debugHelper".attachToRemote()<CR>',"attach to remote"},
        s = { ':lua local widgets=require"dap.ui.widgets";widgets.centered_float(widgets.scopes)<CR>', "centered_float" },
    },
    f = {
        name = "+File",
        m = { "<cmd>lua require'utils'.open_md()<cr>", "open a markdown file in vscode" },
        s = { "<cmd>w<cr>", "save file" },
        t = { "<cmd>NvimTreeToggle<cr>", "toggle nvim tree" },
        r = { "<cmd>RnvimrToggle<cr>", "toggle rnvimr" },
        y = { "<cmd>lua require'utils'.yank_filepath()<cr>", "copy the file path" },
        d = { "<cmd>lua require'utils'.yank_file_dir()<cr>", "copy the file path" },
        l = { "<cmd>NvimTreeFindFile<CR>", "find file" },
        -- T = {"<cmd>let @+ = 'go test -v -run='+expand('<cword>')<cr>", "get current word in go test"},
    },
    g = {
        name = "+Git",
		    m = {"<cmd>Gvdiff master:%<cr>", "Diff with master"},
        j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
        k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
        l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
        p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
        r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
        R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
        s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
        S = { "<cmd>lua require 'gitsigns'.stage_buffer()<cr>", "Stage Buffer" },
        u = {
            "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
            "Undo Stage Hunk",
        },
        o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
        b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
        c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
        C = {
            "<cmd>Telescope git_bcommits<cr>",
            "Checkout commit(for current file)",
        },
        d = {
            "<cmd>Gitsigns diffthis HEAD<cr>",
            "Git Diff",
        },
    },
    l = {
        name = "+Language",
        a = { "<cmd>Lspsaga code_action<cr>", "Code Action" },
        A = { "<cmd>Lspsaga range_code_action<cr>", "Selected Action" },
        d = { "<cmd>Telescope lsp_document_diagnostics<cr>", "Document Diagnostics" },
        D = { "<cmd>Telescope lsp_workspace_diagnostics<cr>", "Workspace Diagnostics" },
        f = { "<cmd>LspFormatting<cr>", "Format" },
        F = { "<cmd>Lspsaga lsp_finder<cr>", "LSP Finder" },
        -- i = {"<cmd>Telescope lsp_implementations<cr>", "implement"},
        i = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "implement" },
        l = { "<cmd>lua vim.lsp.buf.hover()<cr>", "hover" },
        L = { "<cmd>Lspsaga show_line_diagnostics<cr>", "Line Diagnostics" },
        k = { "<cmd>: LspRestart<cr>", "restart lsp server" },
        n = { "<cmd>lua vim.lsp.diagnostic.goto_next()<cr>", "next diagnostic" },
        o = { "<cmd>: SymbolsOutline<cr>", "symbols outline" },
        p = { "<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>", "prev diagnostic" },
        P = { "<cmd>Lspsaga preview_definition<cr>", "Preview Definition" },
        q = { "<cmd>Telescope quickfix<cr>", "Quickfix" },
        r = { "<cmd>lua vim.lsp.buf.references()<cr>", "references" },
        R = { "<cmd>Lspsaga rename<cr>", "Rename" },
        t = { "<cmd>LspTypeDefinition<cr>", "Type Definition" },
        x = { "<cmd>cclose<cr>", "Close Quickfix" },
        s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
        S = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols" },
        z = { "<cmd>LspInfo<cr>", "Info" },
        [","] = { "<cmd>LspInstallInfo<cr>", "LSP servers" }
    },
    p = {
        name = "Packer",
        c = { "<cmd>PackerCompile<cr>", "Compile" },
        i = { "<cmd>PackerInstall<cr>", "Install" },
        s = { "<cmd>PackerSync<cr>", "Sync" },
        S = { "<cmd>PackerStatus<cr>", "Status" },
        u = { "<cmd>PackerUpdate<cr>", "Update" },
    },
    q = {
        name = "quit",
        q = { "<cmd>qall<cr>", "quit" },
    },
    s = {
        name = "+Search",
        b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
        -- c = {"<cmd>Telescope colorscheme<cr>", "Colorscheme"},
        c = { "<cmd>:nohl<cr>", "no highlight" },
        d = { "<cmd>Telescope lsp_document_diagnostics<cr>", "Document Diagnostics" },
        D = { "<cmd>Telescope lsp_workspace_diagnostics<cr>", "Workspace Diagnostics" },
        f = { "<cmd>Fzflua files<cr>", "Find File" },
        m = { "<cmd>Telescope marks<cr>", "Marks" },
        M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
        r = { "<cmd>FzfLua oldfiles<cr>", "Open Recent File" },
        R = { "<cmd>Telescope registers<cr>", "Registers" },
        t = { "<cmd>FzfLua live_grep<cr>", "Text" },
        ["#"] = { "<cmd>FzfLua grep_cword<cr>", "Search word under cursor" },
    },
    S = {
        name = "+Session",
        s = { "<cmd>SessionSave<cr>", "Save Session" },
        l = { "<cmd>SessionLoad<cr>", "Load Session" },
    },
    t = {
        name = "+Test",
        a = { "<cmd>TestSuite -v -cover<cr>", "TestSuite" },
        t = { "<cmd>lua require('neotest').run.run() <cr>", "TestNearest" },
        f = { '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>', "TestFile" },
        c = { "<cmd>GoCover<cr>", "go coverage" },
        C = { "<cmd>GoCoverClear<cr>", "go coverage clear" },
        b = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "set break point" },
        r = { "<cmd>lua require'dap'.continue()<cr>", "continue" },
    },

    -- extras
    z = {
        name = "+Zen",
        s = { "<cmd>TZBottom<cr>", "toggle status line" },
        t = { "<cmd>TZTop<cr>", "toggle tab bar" },
        z = { "<cmd>TZAtaraxis<cr>", "toggle zen" },
    }
}

local wk = require("which-key")
wk.register(mappings, opts)


local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- no hl
keymap.set('n', '<Leader>h', ':set hlsearch!<CR>', { noremap = true, silent = true })

-- explorer
keymap.set('n', '<Leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- telescope
-- keymap.set('n', '<C-p>', ":lua require'telescope.builtin'.find_files()<CR>", {noremap = true, silent = true})
keymap.set('n', '<C-p>', ":FzfLua files<CR>", { noremap = true, silent = true })

-- dashboard
keymap.set('n', '<Leader>;', ':Dashboard<CR>', { noremap = true, silent = true })

-- Comments
keymap.set("n", "<Leader>b/", ":CommentToggle<CR>", { noremap = true, silent = true })
keymap.set("v", "<Leader>b/", ":CommentToggle<CR>", { noremap = true, silent = true })

-- close buffer
keymap.set("n", "<leader>c", ":BufferClose<CR>", { noremap = true, silent = true })

keymap.set('n', '-', ':RnvimrToggle<CR>', opts )

-- better window movement
keymap.set('n', '<C-h>', '<C-w>h', { silent = true })
keymap.set('n', '<C-j>', '<C-w>j', { silent = true })
keymap.set('n', '<C-k>', '<C-w>k', { silent = true })
keymap.set('n', '<C-l>', '<C-w>l', { silent = true })

-- better edit
keymap.set('n', 'Y', 'y$', {})

-- resize with arrows
keymap.set('n', '<C-Up>', ':resize -2<CR>', { silent = true })
keymap.set('n', '<C-Down>', ':resize +2<CR>', { silent = true })
keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', { silent = true })
keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { silent = true })

-- better indenting
keymap.set('v', '<', '<gv', { noremap = true, silent = true })
keymap.set('v', '>', '>gv', { noremap = true, silent = true })

-- I hate escape
keymap.set('i', 'jk', '<ESC>', { noremap = true, silent = true })
keymap.set('i', 'kj', '<ESC>', { noremap = true, silent = true })
keymap.set('i', 'jj', '<ESC>', { noremap = true, silent = true })

-- Tab switch buffer
keymap.set('n', '<TAB>', ':bnext<CR>', { noremap = true, silent = true })
keymap.set('n', '<S-TAB>', ':bprevious<CR>', { noremap = true, silent = true })

-- Move selected line / block of text in visual mode
keymap.set('x', 'K', ':move \'<-2<CR>gv-gv', { noremap = true, silent = true })
keymap.set('x', 'J', ':move \'>+1<CR>gv-gv', { noremap = true, silent = true })

keymap.set('', '<C-q>', ':call QuickFixToggle()<CR>', { noremap = true, silent = true })

-- -- Better nav for omnicomplete
-- vim.cmd('inoremap <expr> <c-j> (\"\\<C-n>\")')
-- vim.cmd('inoremap <expr> <c-k> (\"\\<C-p>\")')

-- vim.cmd('vnoremap p "0p')
-- vim.cmd('vnoremap P "0P')
