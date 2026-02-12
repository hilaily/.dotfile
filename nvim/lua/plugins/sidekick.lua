return {
	{
		"folke/sidekick.nvim",
		dependencies = {
			"folke/snacks.nvim", -- sidekick 推荐的 prompt / cli picker 支持
			"nvim-treesitter/nvim-treesitter", -- 可选，但推荐用于 diff 窗口高亮
		},
		opts = {
			-- 配置 CLI 工具
			cli = {
				tools = {
					gemini = {
						-- Gemini CLI 命令
						cmd = { "gemini" },
						-- 传递给 gemini 命令的参数
						args = {},
						-- 环境变量配置
						-- 不设置 GEMINI_API_KEY，让 Gemini CLI 使用已缓存的 OAuth 凭证
						env = {
							-- 代理配置（如果需要通过代理访问）
							-- 从环境变量读取代理设置，如果没有设置则使用系统默认
							HTTP_PROXY = os.getenv("HTTP_PROXY") or os.getenv("http_proxy"),
							HTTPS_PROXY = os.getenv("HTTPS_PROXY") or os.getenv("https_proxy"),
							ALL_PROXY = os.getenv("ALL_PROXY") or os.getenv("all_proxy"),
							NO_PROXY = os.getenv("NO_PROXY") or os.getenv("no_proxy"),
						},
					},
				},
				-- 设置默认工具
				default = "gemini",
			},
		},
		config = function(_, opts)
			require("sidekick").setup(opts)
			-- 在配置加载后设置快捷键
			vim.keymap.set("n", "<leader>as", function()
				local sidekick = require("sidekick.cli")
				sidekick.toggle({ name = "gemini", focus = true })
			end, { desc = "Sidekick: Toggle Gemini CLI" })
		end,
	},
}

