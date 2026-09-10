return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim", -- optional
  },
  config = true,
  keys = {
    {
      "<leader>gg",
      "<cmd>Neogit<cr>",
      desc = "Open Neogit",
    },
  },
}
