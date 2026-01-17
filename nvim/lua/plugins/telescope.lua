return {
	{
		"telescope.nvim",
		dependencies = {
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				-- 确保编译成功，如果 make 失败，尝试 cmake
				cond = function()
					return vim.fn.executable("make") == 1 or vim.fn.executable("cmake") == 1
				end,
			},
			"nvim-telescope/telescope-file-browser.nvim",
		},
		keys = {
			{
				"<leader>fP",
				function()
					require("telescope.builtin").find_files({
						cwd = require("lazy.core.config").options.root,
					})
				end,
				desc = "Find Plugin File",
			},
			-- {
			-- 	"<leader>sr",
			-- 	function()
			-- 		require("telescope.builtin").oldfiles({
			-- 			cwd = vim.loop.cwd()
			-- 		})
			-- 	end,
			-- 	desc = "Find Recent File",
			-- },
			{
				";f",
				function()
					local builtin = require("telescope.builtin")
					builtin.find_files({
						no_ignore = false,
						hidden = true,
					})
				end,
				desc = "Lists files in your current working directory, respects .gitignore",
			},
			{
				";r",
				function()
					local builtin = require("telescope.builtin")
					builtin.live_grep({
						additional_args = { "--hidden" },
					})
				end,
				desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore",
			},
			{
				"\\\\",
				function()
					local builtin = require("telescope.builtin")
					builtin.buffers()
				end,
				desc = "Lists open buffers",
			},
			{
				";t",
				function()
					local builtin = require("telescope.builtin")
					builtin.help_tags()
				end,
				desc = "Lists available help tags and opens a new window with the relevant help info on <cr>",
			},
			{
				";;",
				function()
					local builtin = require("telescope.builtin")
					builtin.resume()
				end,
				desc = "Resume the previous telescope picker",
			},
			{
				";e",
				function()
					local builtin = require("telescope.builtin")
					builtin.diagnostics()
				end,
				desc = "Lists Diagnostics for all open buffers or a specific buffer",
			},
			{
				";s",
				function()
					local builtin = require("telescope.builtin")
					builtin.treesitter()
				end,
				desc = "Lists Function names, variables, from Treesitter",
			},
			{
				"sf",
				function()
					local telescope = require("telescope")

					local function telescope_buffer_dir()
						return vim.fn.expand("%:p:h")
					end

					telescope.extensions.file_browser.file_browser({
						path = "%:p:h",
						cwd = telescope_buffer_dir(),
						respect_gitignore = false,
						hidden = true,
						grouped = true,
						previewer = false,
						initial_mode = "normal",
						layout_config = { height = 40 },
					})
				end,
				desc = "Open File Browser with the path of the current buffer",
			},
		},
		config = function(_, opts)
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local fb_actions = require("telescope").extensions.file_browser.actions
			local trouble = require("trouble.sources.telescope")

			-- 确保 opts 和其子表存在
			opts = opts or {}
			opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
				wrap_results = true,
				layout_strategy = "horizontal",
				layout_config = { prompt_position = "top" },
				sorting_strategy = "ascending",
				winblend = 0,
				-- 确保文件查找器正常工作
				file_ignore_patterns = {
					"^.git/",
					"^node_modules/",
					"^.DS_Store",
				},
				-- 使用 fzf 排序（如果可用）
				path_display = { "truncate" },
				dynamic_preview_title = true,
				mappings = {
					i = {
						["<C-c>"] = actions.close,
						["<ESC>"] = actions.close,
					["<C-j>"] = actions.move_selection_next,
					["<C-k>"] = actions.move_selection_previous,
					["<c-t>"] = trouble.open,
					["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
					},
					n = {
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
						["<c-t>"] = trouble.open,
						["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist
					},
				},
			})
			opts.pickers = vim.tbl_deep_extend("force", opts.pickers or {}, {
				diagnostics = {
					theme = "ivy",
					initial_mode = "normal",
					layout_config = {
						preview_cutoff = 9999,
					},
				},
			})
			
			-- Configure live_grep: use ripgrep if available, otherwise fallback to grep
			-- Note: Install ripgrep for better performance: brew install ripgrep
			if vim.fn.executable("rg") == 0 then
				vim.notify("ripgrep (rg) not found. live_grep will use grep (slower). Install with: brew install ripgrep", vim.log.levels.WARN)
				opts.defaults = opts.defaults or {}
				opts.defaults.vimgrep_arguments = {
					"grep",
					"--recursive",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
				}
			end
			opts.extensions = vim.tbl_deep_extend("force", opts.extensions or {}, {
				file_browser = {
					theme = "dropdown",
					-- disables netrw and use telescope-file-browser in its place
					hijack_netrw = true,
					mappings = {
						-- your custom insert mode mappings
						["n"] = {
							-- your custom normal mode mappings
							["N"] = fb_actions.create,
							["h"] = fb_actions.goto_parent_dir,
							["/"] = function()
								vim.cmd("startinsert")
							end,
							["<C-u>"] = function(prompt_bufnr)
								for i = 1, 10 do
									actions.move_selection_previous(prompt_bufnr)
								end
							end,
							["<C-d>"] = function(prompt_bufnr)
								for i = 1, 10 do
									actions.move_selection_next(prompt_bufnr)
								end
							end,
							["<PageUp>"] = actions.preview_scrolling_up,
							["<PageDown>"] = actions.preview_scrolling_down,
						},
					},
				},
			})
			telescope.setup(opts)
			
			-- 安全地加载扩展
			pcall(function()
				require("telescope").load_extension("fzf")
			end)
			pcall(function()
				require("telescope").load_extension("file_browser")
			end)
		end,
	},
}