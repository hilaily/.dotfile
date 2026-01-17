return {
	{
		"olimorris/codecompanion.nvim",
		enabled = false, -- 临时禁用 CodeCompanion
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		keys = {
			{ "<leader>a", nil, desc = "CodeCompanion" },
			{ "<leader>ac", "<cmd>CodeCompanionChat<cr>", desc = "CodeCompanion Chat" },
			{ "<leader>ai", "<cmd>CodeCompanionInline<cr>", desc = "CodeCompanion Inline" },
			{ "<leader>am", "<cmd>CodeCompanionCmd<cr>", desc = "CodeCompanion Cmd" },
			{ "<leader>at", "<cmd>CodeCompanionToggle<cr>", desc = "CodeCompanion Toggle" },
		},
		opts = {
			-- 配置策略，使用 gemini_cli adapter
			strategies = {
				chat = {
					adapter = "gemini_cli", -- chat 模式使用 gemini_cli
				},
				inline = {
					adapter = "gemini_cli", -- inline 模式使用 gemini_cli
				},
				cmd = {
					adapter = "gemini_cli", -- cmd 模式使用 gemini_cli
				},
			},
			-- 配置 adapters
			adapters = {
				acp = {
					gemini_cli = function()
						return require("codecompanion.adapters").extend("gemini_cli", {
							-- 使用 OAuth 登录方式，不使用 API key
							defaults = {
								auth_method = "oauth", -- 使用 OAuth 网页登录
								timeout = 20000,
							},
							-- 不设置 GEMINI_API_KEY，强制使用 OAuth 登录
							env = {
								-- 不设置 GEMINI_API_KEY，让 Gemini CLI 使用已缓存的 OAuth 凭证
								-- 代理配置（如果需要通过代理访问）
								HTTP_PROXY = os.getenv("HTTP_PROXY") or os.getenv("http_proxy"),
								HTTPS_PROXY = os.getenv("HTTPS_PROXY") or os.getenv("https_proxy"),
								ALL_PROXY = os.getenv("ALL_PROXY") or os.getenv("all_proxy"),
								NO_PROXY = os.getenv("NO_PROXY") or os.getenv("no_proxy"),
							},
							-- Gemini CLI 命令配置
							commands = {
								default = { "gemini", "cli", "--experimental-acp" },
							},
						})
					end,
				},
			},
		},
	},
}

