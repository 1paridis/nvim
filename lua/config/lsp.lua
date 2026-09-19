-- Mason 安装目录（Mason v2 会设置 $MASON）
local mason_root = vim.fn.expand("$MASON")
if mason_root == "" then
    mason_root = vim.fn.stdpath("data") .. "/mason"
end

-- 让 TypeScript 服务器（vtsls）通过插件支持 .vue 中的 TS
local vue_plugin = {
    name = "@vue/typescript-plugin",
    location = mason_root .. "/packages/vue-language-server/node_modules/@vue/language-server",
    languages = { "vue" },
    configNamespace = "typescript",
}

local ts_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" }

-- 为所有 LSP 注入 blink.cmp 的能力（补全、snippet 等）
local ok, blink = pcall(require, "blink.cmp")
if ok then
    vim.lsp.config("*", {
        capabilities = blink.get_lsp_capabilities(),
    })
end

-- TypeScript / JavaScript（含 .vue 内的 TS）
vim.lsp.config("vtsls", {
    filetypes = ts_filetypes,
    settings = {
        vtsls = {
            -- 使用 vtsls 自带的 TypeScript，避免项目内旧版 TS 与 Vue 插件不兼容
            autoUseWorkspaceTsdk = false,
            tsserver = {
                globalPlugins = { vue_plugin },
            },
        },
    },
})

vim.lsp.enable({
    -- "lua_ls",
    "vtsls",
    "vue_ls",
    "cssls",
    "html",
    "tailwindcss",
    "eslint",
    "emmet_language_server",
})

vim.diagnostic.config({
    virtual_text = false,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = true,
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
            [vim.diagnostic.severity.WARN] = "WarningMsg",
        },
    },
})
