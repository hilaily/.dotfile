return {
	-- Override LazyVim's default LSP keymaps
	{
		"neovim/nvim-lspconfig",
		keys = {
			-- Delete LazyVim's default gd mapping if it exists
			{ "gd", false },
			-- Add our custom gd mapping with higher priority
			{
				"gd",
				function()
					vim.lsp.buf.definition()
				end,
				desc = "Goto Definition",
				noremap = true,
				silent = true,
			},
			-- Delete and re-add other LSP mappings to ensure they work
			{ "gD", false },
			{
				"gD",
				function()
					vim.lsp.buf.declaration()
				end,
				desc = "Goto Declaration",
				noremap = true,
				silent = true,
			},
			{ "gi", false },
			{
				"gi",
				function()
					vim.lsp.buf.implementation()
				end,
				desc = "Goto Implementation",
				noremap = true,
				silent = true,
			},
			{ "K", false },
			{
				"K",
				function()
					vim.lsp.buf.hover()
				end,
				desc = "Hover Documentation",
				noremap = true,
				silent = true,
			},
			{ "gt", false },
			{
				"gt",
				function()
					vim.lsp.buf.type_definition()
				end,
				desc = "Goto Type Definition",
				noremap = true,
				silent = true,
			},
			{ "gr", false },
			{
				"gr",
				function()
					vim.lsp.buf.references()
				end,
				desc = "References",
				noremap = true,
				silent = true,
			},
		},
	},
}

