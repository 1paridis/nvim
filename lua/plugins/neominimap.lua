return {
  "Isrothy/neominimap.nvim",
  version = "v3.x.x",
  lazy = false,
  keys = {
    { "<leader>mm", "<cmd>Neominimap Toggle<cr>", desc = "Toggle Minimap" },
    { "<leader>mf", "<cmd>Neominimap ToggleFocus<cr>", desc = "Toggle Minimap Focus" },
    { "<leader>mr", "<cmd>Neominimap Refresh<cr>", desc = "Refresh Minimap" },
  },
  init = function()
    -- 为右侧浮动缩略图保留水平滚动空间，避免遮挡光标。
    vim.opt.sidescrolloff = 36

    vim.g.neominimap = {
      auto_enable = true,
      layout = "float",
      float = { minimap_width = 20 },
      exclude_filetypes = { "help", "bigfile", "lazy", "mason", "neo-tree" },
    }
  end,
}
