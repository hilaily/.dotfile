require("neotest").setup({
  adapters = {
    require("neotest-go")({
      experimental = {
        test_table = true,
      },
      args = { "-gcflags=all=-l", "-count=1", "-timeout=60s" }
    })
  }
})
