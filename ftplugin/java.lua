-- 设置 Java 缩进为 4 个空格
vim.bo.shiftwidth = 4     -- 自动缩进和重复缩进的宽度
vim.bo.tabstop = 4        -- 制表符的显示宽度
vim.bo.softtabstop = 4    -- 按 Tab 时的实际宽度（结合 expandtab 生效）
vim.bo.expandtab = true   -- 将制表符转换为空格（Java 常用规范）
vim.bo.smartindent = true -- 智能缩进（如大括号后自动缩进）
