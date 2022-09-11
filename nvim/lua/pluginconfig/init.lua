-- source plugin config

require('pluginconfig/barbar')
require('pluginconfig/dashboard-nvim')
require('pluginconfig/galaxyline')
require('pluginconfig/gitsigns')
require('pluginconfig/hop')
require('pluginconfig/lspinstall')
require('pluginconfig/lua-dev') -- must before lspconfig
require('pluginconfig/mkdx')
require('pluginconfig/neotest')
require('pluginconfig/numb')
require('pluginconfig/nvim-autopairs')
require('pluginconfig/nvim-colorizer')
require('pluginconfig/nvim-compe')
require('pluginconfig/fzf-lua')
require('pluginconfig/nvim-tree') -- This plugin must be required somewhere before colorscheme.  Placing it after will break navigation keymappings
require('pluginconfig/nvim-treesitter')
require('pluginconfig/rnvimr')
require('pluginconfig/telescope')
require('pluginconfig/toggleterm')
require('pluginconfig/vim-matchup')
require('pluginconfig/which-key')


-- nvim_comment
require('nvim_comment').setup()

-- lsp-rooter
require("lsp-rooter").setup {
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
}

-- lsp signature
require("lsp_signature").setup()
