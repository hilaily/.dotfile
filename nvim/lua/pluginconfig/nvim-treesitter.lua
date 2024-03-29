local treesitter = {
    ensure_installed = "all",
    highlight = { enabled = true },
    playground = { enabled = true },
    rainbow = { enabled = false },
}

require 'nvim-treesitter.configs'.setup {
    ensure_installed = treesitter.ensure_installed, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    ignore_install = { "haskell", "markdown", "swift" },
    matchup = {
        enable = true, -- mandatory, false will disable the whole extension
        -- disable = { "c", "ruby" },  -- optional, list of language that will be disabled
    },
    highlight = {
        enable = true, -- false will disable the whole extension
        disable = { "markdown" },
    },
    context_commentstring = {
        enable = true,
        config = {
            css = '// %s'
        }
    },
    -- indent = {enable = true, disable = {"python", "html", "javascript"}},
    -- TODO seems to be broken
    indent = { enable = { "javascriptreact" } },
    autotag = { enable = true },
}
