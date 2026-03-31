return {
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"stylua",
				"selene",
				"luacheck",
				"shfmt",
				"pylyzer",
				"buf", -- Protocol Buffers LSP

				-- TypeScript/JavaScript
				"typescript-language-server",
				"eslint-lsp",
				"prettierd",

				-- Go
				"gopls",
				"goimports",
				"gofumpt",
				"golangci-lint",
				"delve",
			})
		end,
	},
}
