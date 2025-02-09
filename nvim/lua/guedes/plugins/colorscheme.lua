return {
    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    priority = 1000,
    config = function()
        -- Optional: configure the colorscheme here
        require('kanagawa').setup({
            -- your config goes here
        })

        -- Set the colorscheme
        vim.cmd([[colorscheme kanagawa]])
    end,
}
