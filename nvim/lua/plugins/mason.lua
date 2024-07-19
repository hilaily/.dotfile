return {
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"stylua",
				"selene",
				"luacheck",
				--"bashls",
				"shfmt",
				-- "tailwindcss",
				-- "tsserver",
				"pylyzer",
				-- "cssls",
			})
		end,
	},
}
