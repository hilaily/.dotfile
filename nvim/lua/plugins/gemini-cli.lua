return {
	{
		"marcinjahn/gemini-cli.nvim",
		cmd = "Gemini", -- 懒加载，使用 :Gemini 命令时加载
		dependencies = {
			"folke/snacks.nvim", -- 必需的依赖
		},
		keys = {
			{ "<leader>aa", "<cmd>Gemini ask<cr>", desc = "Ask Gemini" },
			{ "<leader>ac", "<cmd>Gemini toggle<cr>", desc = "Toggle Gemini CLI" },
			{ "<leader>af", "<cmd>Gemini add_file<cr>", desc = "Add File to Gemini" },
			{ "<leader>ar", "<cmd>Gemini --resume<cr>", desc = "Resume Gemini" },
		},
		config = function()
			require("gemini_cli").setup({
				-- Gemini CLI 命令
				gemini_cmd = "gemini",
				-- 传递给 gemini 命令的参数
				args = {},
				-- 自动重新加载
				auto_reload = false,
				-- 选择器配置
				picker_cfg = {
					preset = "vscode",
				},
				-- 窗口配置
				win = {
					wo = { winbar = "GeminiCLI" },
					style = "gemini_cli",
					position = "right", -- 窗口位置：right, left, top, bottom
				},
				-- 代理配置（如果需要）
				-- 代理会从环境变量 HTTP_PROXY, HTTPS_PROXY, ALL_PROXY 自动读取
			})
		end,
	},
}

