local function keymapping(cmp)
	return {
	  -- 上一个
	  ['<C-k>'] = cmp.mapping.select_prev_item(),
	  -- 下一个
	  ['<C-j>'] = cmp.mapping.select_next_item(),
	  -- 出现补全
	  ['<A-.>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
	  -- 取消
	  ['<A-,>'] = cmp.mapping({
		i = cmp.mapping.abort(),
		c = cmp.mapping.close(),
	  }),
	  -- 确认
	  -- Accept currently selected item. If none selected, `select` first item.
	  -- Set `select` to `false` to only confirm explicitly selected items.
	  ['<CR>'] = cmp.mapping.confirm({
		select = true,
		behavior = cmp.ConfirmBehavior.Replace
	  }),
	  -- ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
	  ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
	  ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
	}
end

local function opts_func (_, opts)
	local cmp = require("cmp")
	-- Use buffer source for `/`.
	cmp.setup.cmdline('/', {
	sources = {
		{ name = 'buffer' },
		{ name = "emoji" },
	}
	})

	-- Use cmdline & path source for ':'.
	cmp.setup.cmdline(':', {
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	})
	})
	return {
		mapping = keymapping(cmp),
		sources = cmp.config.sources({
			{ name = 'nvim_lsp' },
			-- For vsnip users.
			{ name = 'vsnip' },
			-- For luasnip users.
			-- { name = 'luasnip' },
			--For ultisnips users.
			-- { name = 'ultisnips' },
			-- -- For snippy users.
			-- { name = 'snippy' },
			{ name = 'emoji'}
		  }, { { name = 'buffer' },
			{ name = 'path' }
		  }),
		snippet = {
		expand = function(args)
			-- For `vsnip` users.
			vim.fn["vsnip#anonymous"](args.body)
	
			-- For `luasnip` users.
			-- require('luasnip').lsp_expand(args.body)
	
			-- For `ultisnips` users.
			-- vim.fn["UltiSnips#Anon"](args.body)
	
			-- For `snippy` users.
			-- require'snippy'.expand_snippet(args.body)
		end,
		},
	}
end

return {
	{
		"nvim-cmp",
		dependencies = { "hrsh7th/cmp-emoji" },
		opts = opts_func,
	},
}