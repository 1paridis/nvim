return {
    {
        "stevearc/conform.nvim",
        cmd = "ConformInfo",
        opts = {
            -- 内置 prettier 优先查找项目 node_modules/.bin，再从 PATH（含 Mason）查找。
            formatters_by_ft = {
                javascript = { "prettier", name = "vtsls" },
                javascriptreact = { "prettier", name = "vtsls" },
                typescript = { "prettier", name = "vtsls" },
                typescriptreact = { "prettier", name = "vtsls" },
                vue = { "prettier", name = "vue_ls" },
                css = { "prettier", name = "cssls" },
                scss = { "prettier", name = "cssls" },
                less = { "prettier", name = "cssls" },
                html = { "prettier", name = "html" },
                json = { "prettier" },
                jsonc = { "prettier" },
                yaml = { "prettier" },
                markdown = { "prettier" },
                lua = { "stylua" },
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
            -- 保留手动格式化，不额外启用保存时格式化。
        },
    },
}
