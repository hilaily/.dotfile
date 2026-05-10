return {
	"folke/sidekick.nvim",
	enabled = true,
	opts = {
		cli = {
			mux = {
				backend = vim.env.ZELLIJ and "zellij" or "tmux",
				enabled = vim.fn.executable("zellij") == 1 or vim.fn.executable("tmux") == 1,
			},
		},
	},
	keys = {
		{
			"<C-\\>",
			function()
				require("sidekick.cli").toggle()
			end,
			mode = { "n", "i", "t" },
			desc = "Sidekick Toggle",
		},
		{
			"<leader>ao",
			function()
				require("sidekick.cli").toggle({ focus = true })
			end,
			desc = "Sidekick Open",
		},
		{
			"<leader>ax",
			function()
				require("sidekick.cli").hide()
			end,
			desc = "Sidekick Close",
		},
		{
			"<leader>aa",
			function()
				require("sidekick.cli").toggle()
			end,
			desc = "Sidekick Toggle",
		},
		{
			"<leader>as",
			function()
				require("sidekick.cli").select()
			end,
			-- Or to select only installed tools:
			-- require("sidekick.cli").select({ filter = { installed = true } })
			desc = "Select CLI",
		},
		{
			"<leader>ad",
			function()
				require("sidekick.cli").close()
			end,
			desc = "Detach a CLI Session",
		},
		{
			"<leader>at",
			function()
				require("sidekick.cli").send({ msg = "{this}" })
			end,
			mode = { "x", "n" },
			desc = "Send This",
		},
		{
			"<leader>af",
			function()
				require("sidekick.cli").send({ msg = "{file}" })
			end,
			desc = "Send File",
		},
		{
			"<leader>av",
			function()
				require("sidekick.cli").send({ msg = "{selection}" })
			end,
			mode = { "x" },
			desc = "Send Visual Selection",
		},
		{
			"<leader>ap",
			function()
				require("sidekick.cli").prompt()
			end,
			mode = { "n", "x" },
			desc = "Sidekick Select Prompt",
		},
	},
}
