return {
    {
        "rmagatti/auto-session",
        lazy = false,
        ---@module "auto-session"
        ---@type AutoSession.Config
        opts = {
            auto_session_use_git_branch = true,
        },
        keys = {
            { "<leader>qs", "<cmd>AutoSession search<CR>",  desc = "Select Session" },
            { "<leader>ql", "<cmd>AutoSession restore<CR>", desc = "Restore Last Session" },
            { "<leader>qd", "<cmd>AutoSession delete<CR>",  desc = "Delete Session" },
        },
    },
}
