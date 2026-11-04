return {
    {
        "1paridis/java-maven.nvim",
        main = "java_maven",
        lazy = true,
        ft = { "java" },
        cmd = { "JavaMavenDebug" },
        dependencies = { "mfussenegger/nvim-dap", "mfussenegger/nvim-jdtls" },
        opts = {},
    },
}
