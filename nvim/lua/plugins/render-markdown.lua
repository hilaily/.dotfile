return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		ft = { "markdown", "mdx", "quarto", "rmd", "org" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			-- 未安装 tectonic/pdflatex 时关闭 LaTeX 公式渲染，减少健康检查噪音
			latex = { enabled = false },
		},
	},
}
