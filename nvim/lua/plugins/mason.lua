return {
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
		vim.list_extend(opts.ensure_installed, {
			"stylua",
			"selene",
			"luacheck",
			--"bashls",
			"shfmt",
			--"tailwindcss",
			"typescript-language-server", -- TypeScript/JavaScript LSP
			"pylyzer",
			--"cssls",
			"buf", -- Protocol Buffers LSP
			"gopls", -- Go LSP
		})
		end,
	},
}
