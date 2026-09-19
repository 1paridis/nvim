return {
    {
        "neovim/nvim-lspconfig",
        lazy = false, -- 提供 lsp/*.lua 服务器定义，需在 config.lsp 之前加载
        dependencies = { "mason.nvim" },
    },
}
