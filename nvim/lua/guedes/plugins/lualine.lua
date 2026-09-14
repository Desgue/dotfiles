return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        -- "auto" derives the statusline colors from the active colorscheme.
        require("lualine").setup({ options = { theme = "auto" } })
    end
}
