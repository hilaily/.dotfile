return {
	{
		"folke/snacks.nvim",
		opts = {
			image = {
				-- tmux / 部分终端不报 kitty graphics；避免 :checkhealth 里出现 ERROR（仍会 WARN）
				force = true,
			},
		},
	},
}
