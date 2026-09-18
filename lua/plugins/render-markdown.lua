return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "markdown.mdx", "norg", "rmd", "org" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        heading = {
            sign = false,
            icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        },
        code = {
            sign = false,
            style = "full",
        },
        bullet = {
            icons = { "●", "○", "◆", "◇" },
        },
        checkbox = {
            enabled = true,
        },
    },
    keys = {
        { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Render Markdown" },
    },
}
