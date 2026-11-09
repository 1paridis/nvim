local mason = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
local cache = vim.fn.stdpath("cache")
local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "settings.gradle" }

local bundles = vim.fn.glob(mason .. "/share/java-debug-adapter/com.microsoft.java.debug.plugin-*.jar", false, true)
local non_osgi_jars = { "com.microsoft.java.test.runner-jar-with-dependencies.jar", "jacocoagent.jar" }
for _, jar in ipairs(vim.fn.glob(mason .. "/share/java-test/*.jar", false, true)) do
    if not vim.tbl_contains(non_osgi_jars, vim.fs.basename(jar)) then
        table.insert(bundles, jar)
    end
end

return {
    root_dir = function(bufnr, on_dir)
        local uri = vim.uri_from_bufnr(bufnr)
        if vim.startswith(uri, "file://") then
            local maven_root = require("java_maven").root_dir(bufnr)
            local root = maven_root and (vim.uv.fs_realpath(maven_root) or maven_root)
                or vim.fs.root(bufnr, root_markers)
                or vim.fn.getcwd()
            on_dir(root)
        end
    end,
    cmd = function(dispatchers, config)
        local root = config.root_dir
        local workspace = cache .. "/jdtls/" .. vim.fs.basename(root) .. "/workspace"
        if vim.fn.filereadable(root .. "/pom.xml") == 1 then
            workspace = cache .. "/java-maven/jdtls/" .. vim.fn.sha256(root)
        end
        local cmd = {
            "jdtls",
            "-configuration",
            cache .. "/jdtls/config",
            "-data",
            workspace,
            "--jvm-arg=-XX:+UseParallelGC",
            "--jvm-arg=-Xms512m",
            "--jvm-arg=-Xmx2G",
        }

        local lombok_jar = mason .. "/share/jdtls/lombok.jar"
        if vim.fn.filereadable(lombok_jar) == 1 then
            table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok_jar)
        end

        -- 保留实际命令参数，供 JdtWipeDataAndRestart 读取 -data。
        config.cmd = cmd
        return vim.lsp.rpc.start(cmd, dispatchers, {
            cwd = config.cmd_cwd,
            env = config.cmd_env,
            detached = config.detached,
        })
    end,
    init_options = {
        bundles = bundles,
    },
    settings = {
        java = {
            import = {
                gradle = {
                    enabled = true,
                },
                maven = {
                    enabled = true,
                },
            },
            inlayHints = {
                parameterNames = {
                    enabled = "literals",
                },
            },
            implementationCodeLens = "none",
            referencesCodeLens = {
                enabled = false,
            },
            maven = {
                downloadSources = false,
            },
            gradle = {
                downloadSources = false,
            },
            configuration = {
                updateBuildConfiguration = "interactive"
            },
        },
    },
}
