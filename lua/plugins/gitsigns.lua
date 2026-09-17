return {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
        vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { link = "Comment" })
        require("gitsigns").setup({
            current_line_blame = true,
            current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol",
            delay = 500,
            ignore_whitespace = false,
            virt_text_priority = 100,
            format = function(name, date, msg)
                return string.format("%s • %s • %s", name, date, msg)
            end,
        },
        on_attach = function(buffer)
            local wk = require("which-key")
            local gs = require("gitsigns")
            wk.add({
                {
                    mode = "n",
                    buffer = buffer,
                    { "<leader>gh",  group = "Git Blame" },
                    { "<leader>ghb", function() gs.blame_line({ full = true }) end, desc = "Blame Line" },
                    { "<leader>ghB", function() gs.blame() end,                     desc = "Blame Buffer" },
                }
            })
        end
        })
    end,
}
