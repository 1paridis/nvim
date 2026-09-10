-- 设置 Java 缩进为 4 个空格
vim.bo.shiftwidth = 4     -- 自动缩进和重复缩进的宽度
vim.bo.tabstop = 4        -- 制表符的显示宽度
vim.bo.softtabstop = 4    -- 按 Tab 时的实际宽度（结合 expandtab 生效）
vim.bo.expandtab = true   -- 将制表符转换为空格（Java 常用规范）
vim.bo.smartindent = true -- 智能缩进（如大括号后自动缩进）

-- Mason 在运行时通过 `vim.env.MASON` 设置路径，`vim.fn.expand("$MASON")`
-- 读不到它，必须直接用 `vim.env.MASON`。
local mason = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")

local root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "settings.gradle" })
    or vim.fn.getcwd()
local project_name = vim.fn.fnamemodify(root_dir, ":t")

-- OSGi 配置目录全局共用；workspace 按项目隔离，避免串项目
local jdtls_config_dir = vim.fn.stdpath("cache") .. "/jdtls/config"
local jdtls_workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"

local cmd = {
    "jdtls",
    "-configuration",
    jdtls_config_dir,
    "-data",
    jdtls_workspace_dir,
}

local lombok_jar = mason .. "/share/jdtls/lombok.jar"
if vim.fn.filereadable(lombok_jar) == 1 then
    table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok_jar)
end

-- DAP / 测试所需的 bundle
local bundles = vim.fn.glob(mason .. "/share/java-debug-adapter/com.microsoft.java.debug.plugin-*.jar", false, true)
vim.list_extend(bundles, vim.fn.glob(mason .. "/share/java-test/*.jar", false, true))

local config = {
    name = "jdtls",
    cmd = cmd,
    root_dir = root_dir,
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    init_options = {
        bundles = bundles,
    },
    settings = {
        java = {
            import = {
                gradle = {
                    enabled = true
                },
                maven = {
                    enabled = true
                }
            },
            inlayHints = {
              parameterNames = {
                enabled = "all",
              },
            },
            implementationCodeLens = "all",
            referencesCodeLens = {
                enabled = true
            },
            maven = {
                downloadSources = true
            },
            gradle = {
                downloadSources = true
            },
            configuration = {
                updateBuildConfiguration = "interactive"
            },
        },

    }

}

require('jdtls').start_or_attach(config)
