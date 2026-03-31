return {
	-- for format
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				javascript = { "prettierd", "prettier" },
				javascriptreact = { "prettierd", "prettier" },
				typescript = { "prettierd", "prettier" },
				typescriptreact = { "prettierd", "prettier" },
				go = { "goimports", "gofumpt" },
			},
		},
	},
}