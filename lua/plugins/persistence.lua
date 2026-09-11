return {
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        enabled = true,
        opts = {
            need = 1,
            branch = true, 
        },
        config = function(_, opts)
            require("persistence").setup(opts)
            vim.api.nvim_create_autocmd("User", {
                pattern = "PersistenceSavePre",
                callback = function()
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        local name = vim.api.nvim_buf_get_name(buf)
                        if
                            vim.bo[buf].filetype == "neo-tree"
                            or name:match("neo%-tree [%w_]+ %[%d+%]$")
                        then
                            vim.api.nvim_buf_delete(buf, { force = true })
                        end
                    end
                end,
            })
        end,
        -- stylua: ignore
        keys = {
            { "<leader>qs", function() require("persistence").select() end,              desc = "Select Session" },
            { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
            { "<leader>qd", function() require("persistence").stop() end,                desc = "Don't Save Current Session" },
        },
    }
}
