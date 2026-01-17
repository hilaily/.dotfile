return {
	{
		"yetone/avante.nvim",
		opts = function(_, opts)
			-- 配置使用 Gemini CLI 的 ACP (Agent Client Protocol)
			opts.provider = "gemini-cli"
			opts.auto_suggestions_provider = opts.auto_suggestions_provider or "gemini-cli"

			-- 配置 ACP providers
			-- 使用网页登录（OAuth）方式，不需要 API Key
			-- 
			-- 使用步骤：
			-- 1. 首次使用前，在终端运行: gemini auth login
			-- 2. 这会打开浏览器，完成 Google 账号登录
			-- 3. 登录凭证会被缓存到本地（通常在 ~/.gemini 目录）
			-- 4. 之后 avante 会自动使用缓存的凭证，无需 API Key
			--
			-- 注意：如果环境变量中已设置了 GEMINI_API_KEY，Gemini CLI 可能会优先使用它
			-- 如果想强制使用网页登录，请临时取消设置该环境变量：
			--   unset GEMINI_API_KEY  (bash/zsh)
			--   或 set -e GEMINI_API_KEY  (fish)
			opts.acp_providers = opts.acp_providers or {}
			opts.acp_providers["gemini-cli"] = {
				command = "gemini",
				args = { "--experimental-acp" },
				env = {
					NODE_NO_WARNINGS = "1",
					-- 不设置 GEMINI_API_KEY，让 Gemini CLI 使用已缓存的 OAuth 凭证
					-- 如果必须使用 API Key，可以取消下面的注释：
					-- GEMINI_API_KEY = os.getenv("GEMINI_API_KEY"),
				},
				-- 不设置 auth_method，让 CLI 自动使用已缓存的 OAuth 凭证
			}

			-- 可选：配置其他 Gemini provider 设置（用于非 ACP 模式）
			opts.providers = opts.providers or {}
			opts.providers.gemini = opts.providers.gemini or {
				-- 如果将来需要使用 REST API 模式，可以在这里配置
				-- api_key = os.getenv("GEMINI_API_KEY"),
			}

			return opts
		end,
	},
}

