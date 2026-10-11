return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    opts = {
        filesystem = {
            group_empty_dirs = true,
            filtered_items = {
                visible = false,
                hide_dotfiles = false,
                hide_gitignored = true,
            },
            follow_current_file = {
                enabled = true,
                leave_dirs_open = false,
            },
        },
        window = {
            mappings = {
                -- 模拟 snacks explorer：
                -- l：打开文件 / 展开目录
                -- h：关闭目录
                ["l"] = "open",
                ["h"] = "close_node",

                -- -- 可选：让 Z 和 snacks 一样关闭所有目录
                -- ["Z"] = "close_all_nodes",
            },
        },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false, -- neo-tree will lazily load itself
  }
}
