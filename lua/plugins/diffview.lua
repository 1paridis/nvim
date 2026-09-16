return {
  "sindrets/diffview.nvim",
  -- diffview.nvim 由 neogit 作为依赖加载；这里补充 q 关闭映射与 untracked 修复
  config = function()
    require("diffview").setup({})

    -- 修复 neogit 集成：Untracked 段打开 diff 时文件面板为空

    local close_diffview = function()
      vim.cmd("DiffviewClose")
    end

    -- 在 diffview 的所有 buffer（文件面板 DiffviewFiles 与 diff 视图）里按 q 关闭整个 diffview
    vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
      callback = function(args)
        local name = vim.api.nvim_buf_get_name(args.buf)
        if vim.bo[args.buf].filetype == "DiffviewFiles" or vim.startswith(name, "diffview://") then
          vim.keymap.set("n", "q", close_diffview, { buffer = args.buf, silent = true, desc = "Close diffview" })
        end
      end,
    })
  end,
}
