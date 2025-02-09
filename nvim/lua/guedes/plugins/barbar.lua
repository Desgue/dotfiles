return {
    "romgrk/barbar.nvim",
    dependencies = {
        "lewis6991/gitsigns.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    lazy = true,
    event = { "BufReadPost", "BufNewFile" },
    init = function()
        vim.g.barbar_auto_setup = false
    end,
    opts = {
        animation = true,
        insert_at_end = true,
        clickable = true,
        tabpages = false
    },
    version = "^1.0.0",
}
