local function my_on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- default mappings
	api.config.mappings.default_on_attach(bufnr)

	-- custom mappings
	vim.keymap.set("n", "<C-t>", api.tree.change_root_to_parent, opts("Up"))
	vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
	vim.keymap.set("n", "l", api.node.open.edit, opts("Edit"))
	vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Parent Close"))
	vim.keymap.set("n", "s", api.node.open.horizontal, opts("Horizontal Split"))
	vim.keymap.set("n", "v", api.node.open.vertical, opts("Vertical Split"))
	vim.keymap.set("n", "<S-r>", api.tree.reload, opts("Reload"))
end

vim.g.nvim_tree_indent_markers = 1 -- "0 by default, this option shows indent markers when folders are open
vim.g.nvim_tree_auto_ignore_ft = "startify" --empty by default, don't auto open tree on specific filetypes.

vim.g.nvim_tree_icons = {
	default = "",
	symlink = "",
	git = { unstaged = "", staged = "✓", unmerged = "", renamed = "➜", untracked = "" },
	folder = { default = "", open = "", empty = "", empty_open = "", symlink = "" },
}

return {
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons", -- optional
		},
		opts = {
			on_attach = my_on_attach,
			disable_netrw = true,
			hijack_netrw = true,
			--auto_close = false,
			filters = {
				dotfiles = false,
				custom = {},
			},
			git = {
				enable = true,
				ignore = false,
				timeout = 500,
			},
			update_focused_file = {
				-- enables the feature
				enable = true,
				-- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
				-- only relevant when `update_focused_file.enable` is true
				update_cwd = false,
				-- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
				-- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
				ignore_list = {},
			},
		},
	},
}

