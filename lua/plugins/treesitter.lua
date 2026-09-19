return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false, -- main 分支不支持懒加载
        build = ":TSUpdate",
        config = function()
            local treesitter = require("nvim-treesitter")
            local filetypes = {
                "json", "lua", "java", "rust",
                "javascript", "javascriptreact", "typescript", "typescriptreact", "vue",
                "css", "scss", "html",
            }
            local function start(buf)
                if vim.api.nvim_buf_is_loaded(buf) and vim.tbl_contains(filetypes, vim.bo[buf].filetype) then
                    -- 首次启动时解析器可能尚未安装完成。
                    pcall(vim.treesitter.start, buf)
                end
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("ParidisTreesitter", { clear = true }),
                pattern = filetypes,
                callback = function(event)
                    start(event.buf)
                end,
            })

            treesitter.install({
                "json", "lua", "java", "rust",
                "javascript", "typescript", "tsx", "vue",
                "css", "scss", "html",
            }):await(function(err)
                if err then
                    return -- 安装器负责报告错误
                end
                vim.schedule(function()
                    -- 安装完成后也为已经打开的文件启动高亮。
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        start(buf)
                    end
                end)
            end)
        end,
    },
}
