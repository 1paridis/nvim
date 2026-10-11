return {
    -- LSP for Cargo.toml
    {
        "Saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        opts = {
            completion = {
                crates = {
                    enabled = true,
                },
            },
            lsp = {
                enabled = true,
                actions = true,
                completion = true,
                hover = true,
            },
        },

    },
    {
        "mrcjkb/rustaceanvim",
        ft = { "rust" },
        opts = {
            server = {
                on_attach = function(_, bufnr)
                    vim.keymap.set("n", "<leader>cR", function()
                        vim.cmd.RustLsp("codeAction")
                    end, { desc = "Code Action", buffer = bufnr })
                    vim.keymap.set("n", "<leader>dr", function()
                        vim.cmd.RustLsp("debuggables")
                    end, { desc = "Rust Debuggables", buffer = bufnr })
                end,
                default_settings = {
                    -- rust-analyzer language server configuration
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = true,
                            buildScripts = {
                                enable = true,
                            },
                        },
                        -- Enable diagnostics if using rust-analyzer
                        diagnostics = {
                            enable = true,
                        },
                        procMacro = {
                            enable = true,
                            ignored = {
                                ["async-trait"] = { "async_trait" },
                                ["napi-derive"] = { "napi" },
                                ["async-recursion"] = { "async_recursion" },
                            },
                        },
                        files = {
                            excludeDirs = {
                                ".direnv",
                                ".git",
                                ".github",
                                ".gitlab",
                                "bin",
                                "node_modules",
                                "target",
                                "venv",
                                ".venv",
                            },
                        },
                    },
                },
            },
        },
        config = function(_, opts)
            local codelldb = vim.fn.exepath("codelldb")
            local codelldb_lib_ext = io.popen("uname"):read("*l") == "Linux" and ".so" or ".dylib"
            local library_path = vim.fn.stdpath("data") .. "/mason/opt/lldb/lib/liblldb" .. codelldb_lib_ext
            local adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path)
            adapter.enrich_config = require("config.rust_dap").enrich_config
            opts.dap = {
                adapter = adapter,
            }

            vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
            if vim.fn.executable("rust-analyzer") == 0 then
                vim.notify(
                    "**rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/",
                    vim.log.levels.ERROR,
                    { title = "rustaceanvim" }
                )
            end
        end,

    }
}
