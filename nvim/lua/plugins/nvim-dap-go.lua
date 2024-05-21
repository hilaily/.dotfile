return {
	"leoluz/nvim-dap-go",
	keys = {
		{ "<F5>", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
		{ "<F6>",":lua require('dap-go').debug_test()<cr>", desc = "Debug Test" },
		{ "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
		{ "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
		{ "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
		{ "<S-F11>", function() require("dap").step_out() end, desc = "Step Out" },
	}
}