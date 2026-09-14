return {
    "nvim-treesitter/nvim-treesitter",
    tag = "v0.10.0",
    build = ":TSUpdate",
    dependencies = {
        -- Track master: `main` is the rewrite and drops the module API that
        -- nvim-treesitter's master line (and the `textobjects` block below) uses.
        { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" }, -- Syntax aware text-objects
        {
            "nvim-treesitter/nvim-treesitter-context",     -- Show code context
            opts = { enable = true, mode = "topline", line_numbers = true }
        }
    },
    config = function()
        local treesitter = require("nvim-treesitter.configs")

        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "markdown" },
            callback = function(ev)
                -- treesitter-context is buggy with Markdown files
                require("treesitter-context").disable()
            end
        })

        treesitter.setup({
            ensure_installed = {
                "gitignore", "go", "gomod", "gosum",
                "typescript", "javascript", "json", "lua", "markdown", "proto",
                "python", "sql", "yaml",
            },
            indent = { enable = true },
            auto_install = true,
            sync_install = false,
            highlight = {
                enable = true,
            },
            textobjects = { select = { enable = true, lookahead = true } }
        })
    end
}
