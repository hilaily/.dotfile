--return {
--	"greggh/claude-code.nvim",
--	dependencies = {
--		"nvim-lua/plenary.nvim", -- Required for git operations
--	},
--	config = function()
--		require("claude-code").setup({
--			window = {
--				split_ratio = 0.3, -- Percentage of screen for the terminal window (height for horizontal, width for vertical splits)
--				position = "botright", -- Position of the window: "botright", "topleft", "vertical", "rightbelow vsplit", etc.
--				enter_insert = true, -- Whether to enter insert mode when opening Claude Code
--				hide_numbers = true, -- Hide line numbers in the terminal window
--				hide_signcolumn = true, -- Hide the sign column in the terminal window
--			},
--			keymaps = {
--				toggle = {
--					normal = "<leader>cc", -- Normal mode keymap for toggling Claude Code, false to disable
--					terminal = "<C-,>", -- Terminal mode keymap for toggling Claude Code, false to disable
--					variants = {
--						continue = "<leader>cC", -- Normal mode keymap for Claude Code with continue flag
--						verbose = "<leader>cV", -- Normal mode keymap for Claude Code with verbose flag
--					},
--				},
--				window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
--				scrolling = true, -- Enable scrolling keymaps (<C-f/b>) for page up/down
--			},
--		})
--	end,
--}

return {
	"coder/claudecode.nvim",
	config = true,
	keys = {
		{ "<leader>a", nil, desc = "AI/Claude Code" },
		{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
		{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
		{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
		{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
		{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
		{
			"<leader>as",
			"<cmd>ClaudeCodeTreeAdd<cr>",
			desc = "Add file",
			ft = { "NvimTree", "neo-tree", "oil" },
		},
		-- Diff management
		{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
		{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
	},
}
