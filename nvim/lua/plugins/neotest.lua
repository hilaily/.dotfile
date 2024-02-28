return {
	{ "nvim-neotest/neotest-plenary" },
	{
	  "nvim-neotest/neotest",
	  dependencies= {
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-go",
	  },
	  opts = { 
		adapters = {
			require("neotest-go")({
			  experimental = {
				test_table = true,
			  },
			  args = { "-gcflags=all=-l", "-count=1", "-timeout=60s" }
			})
		  }
	  },
	},
  }