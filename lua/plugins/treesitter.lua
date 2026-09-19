return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        build = ":TSUpdate",
        config = function()
            -- import nvim-treesitter plugin
            local treesitter = require("nvim-treesitter")

            treesitter.install{
                'json', 'lua', 'java', 'rust',
                -- frontend
                'javascript', 'typescript', 'tsx', 'vue',
                'css', 'scss', 'html',
            }
        end,
    },
}
