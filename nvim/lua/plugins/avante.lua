return {
	{
		"yetone/avante.nvim",
		enabled = false, -- 临时禁用 avante
		opts = function(_, opts)
			-- 强制使用 Gemini CLI 的 ACP (Agent Client Protocol)
			-- 注意：必须明确设置，覆盖 LazyVim 的默认配置
			opts.provider = "gemini-cli"
			opts.auto_suggestions_provider = "gemini-cli"

			-- 清除可能存在的 claude 配置（如果 LazyVim 设置了的话）
			if opts.claude then
				opts.claude = nil
			end

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
					
					-- 代理配置（如果需要通过代理访问）
					-- 从环境变量读取代理设置，如果没有设置则使用系统默认
					HTTP_PROXY = os.getenv("HTTP_PROXY") or os.getenv("http_proxy"),
					HTTPS_PROXY = os.getenv("HTTPS_PROXY") or os.getenv("https_proxy"),
					ALL_PROXY = os.getenv("ALL_PROXY") or os.getenv("all_proxy"),
					NO_PROXY = os.getenv("NO_PROXY") or os.getenv("no_proxy"),
					
					-- 如果需要手动指定代理，可以取消下面的注释并修改为你的代理地址：
					-- HTTP_PROXY = "http://127.0.0.1:7890",
					-- HTTPS_PROXY = "http://127.0.0.1:7890",
					-- 或者使用 SOCKS5 代理：
					-- ALL_PROXY = "socks5://127.0.0.1:7890",
				},
				-- 不设置 auth_method，让 CLI 自动使用已缓存的 OAuth 凭证
			}

			-- 确保 providers 表中没有 claude 的配置
			opts.providers = opts.providers or {}
			if opts.providers.claude then
				opts.providers.claude = nil
			end

			-- 可选：配置其他 Gemini provider 设置（用于非 ACP 模式）
			opts.providers.gemini = opts.providers.gemini or {
				-- 如果将来需要使用 REST API 模式，可以在这里配置
				-- api_key = os.getenv("GEMINI_API_KEY"),
			}

			-- 调试：打印当前配置的 provider（可选，用于验证）
			-- vim.notify("Avante provider set to: " .. opts.provider, vim.log.levels.INFO)

			return opts
		end,
		-- LazyVim 会自动调用 setup，这里不需要再次调用
		-- 但如果需要验证，可以取消下面的注释
		-- config = function(_, opts)
		-- 	vim.defer_fn(function()
		-- 		local avante = require("avante")
		-- 		if avante and avante.config then
		-- 			local current_provider = avante.config.provider or "unknown"
		-- 			vim.notify("Avante provider: " .. current_provider, vim.log.levels.INFO)
		-- 		end
		-- 	end, 1000)
		-- end,
		-- 确保在 LazyVim 的配置之后加载
		priority = 1000,
	},
}

