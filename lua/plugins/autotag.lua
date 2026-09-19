return {
    "windwp/nvim-ts-autotag",
    lazy = false, -- 插件内部按需挂载，确保首次 InsertEnter 也能生效
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
        opts = {
            enable_close = true,
            -- 改名在 InsertLeave（按 Esc 退出插入模式）时同步另一侧标签。
            enable_rename = true,
            enable_close_on_slash = false,
        },
    },
}
