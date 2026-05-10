return {
	{
		"folke/snacks.nvim",
		opts = {
			-- LazyVim 仍依赖 snacks 核心（通知、dashboard 等）；关闭 picker，统一用 Telescope。
			picker = { enabled = false },
			image = {
				-- tmux / 部分终端不报 kitty graphics；避免 :checkhealth 里出现 ERROR（仍会 WARN）
				force = true,
			},
		},
	},
}
