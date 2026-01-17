return {
	{
		"ibhagwan/fzf-lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			-- 如果需要使用 fzf-lua 的快捷键，可以在这里添加
		},
		config = function()
			require("fzf-lua").setup({
				-- fzf-lua 的配置
				winopts = {
					height = 0.85,
					width = 0.80,
				},
			})
		end,
	},
}

