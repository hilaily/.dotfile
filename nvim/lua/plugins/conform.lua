return {
	-- for format
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				go = { "goimports"},
			}
		}
	}
}