-- Run from the config directory: nvim --headless -u NONE -i NONE -l tests/rust_dap.lua
local helper = dofile("lua/config/rust_dap.lua")
local original_notify, original_system = vim.notify, vim.system
local notifications = {}
vim.notify = function(message)
    notifications[#notifications + 1] = message
end
local root = vim.fn.tempname() .. "/workspace with spaces"
local function write(path, lines)
    vim.fn.mkdir(vim.fs.dirname(path), "p")
    vim.fn.writefile(lines, path)
end
local function base(program, name)
    return {
        type = "codelldb",
        request = "launch",
        name = name or "Rust debug client",
        sourceLanguages = { "rust" },
        cwd = root,
        program = root .. "/target/" .. (program or "debug/web-server"),
    }
end
local function enrich(config)
    local output, calls = nil, 0
    helper.enrich_config(config, function(result)
        output, calls = result, calls + 1
    end)
    assert(
        vim.wait(12000, function()
            return calls > 0
        end, 10),
        "enrich_config timed out"
    )
    assert(calls == 1, "callback must run exactly once")
    return output
end
local function unchanged(config)
    assert(enrich(config) == config, "configuration should be preserved")
end
local function metadata_result(result)
    vim.system = function(_, _, callback)
        vim.schedule(function()
            callback(result)
        end)
    end
end

local ok, err = xpcall(function()
    write(root .. "/Cargo.toml", {
        "[workspace]",
        'members = ["services/*"]',
        'resolver = "2"',
    })
    write(root .. "/services/frontend/Cargo.toml", {
        "[package]",
        'name = "frontend-package"',
        'version = "0.1.0"',
        'edition = "2021"',
        "autobins = false",
        "[[bin]]",
        'name = "web-server"',
        'path = "src/main.rs"',
        "[[bin]]",
        'name = "admin-cli"',
        'path = "src/admin.rs"',
    })
    write(root .. "/services/frontend/src/main.rs", { "fn main() {}" })
    write(root .. "/services/frontend/src/admin.rs", { "fn main() {}" })
    write(root .. "/services/jobs/Cargo.toml", {
        "[package]",
        'name = "queue-worker"',
        'version = "0.1.0"',
        'edition = "2021"',
    })
    write(root .. "/services/jobs/src/main.rs", { "fn main() {}" })

    local config = base()
    assert(enrich(config).cwd == root .. "/services/frontend")
    assert(config.cwd == root, "stored configuration must not be mutated")
    assert(enrich(base("debug/queue-worker", "Cargo: build --package queue-worker ")).cwd == root .. "/services/jobs")
    assert(enrich(base("release/admin-cli")).cwd == root .. "/services/frontend")
    assert(enrich(base("x86_64-unknown-linux-gnu/debug/web-server")).cwd == root .. "/services/frontend")
    assert(enrich(base("debug/web-server.exe")).cwd == root .. "/services/frontend")

    -- Add a new member after the first launch; no stale metadata cache.
    write(root .. "/services/scheduler/Cargo.toml", {
        "[package]",
        'name = "scheduler"',
        'version = "0.1.0"',
        'edition = "2021"',
    })
    write(root .. "/services/scheduler/src/main.rs", { "fn main() {}" })
    assert(enrich(base("debug/scheduler")).cwd == root .. "/services/scheduler")

    unchanged(base("debug/deps/web_server-0123456789abcdef"))
    unchanged(base("debug/examples/web-server"))
    unchanged(base("debug/queue-worker", "Cargo: test --package queue-worker --no-run "))
    unchanged(base(nil, "My manual Rust launch"))
    config = base()
    config.request = "attach"
    unchanged(config)
    config = base()
    config.type = "java"
    unchanged(config)
    config = base()
    config.sourceLanguages = { "cpp" }
    unchanged(config)
    config = base()
    config.cwd = root .. "/services/frontend"
    unchanged(config)
    config = base()
    config.program = root .. "/outside-target/web-server"
    unchanged(config)

    -- Respect launch.json even when its name matches a generated configuration.
    local config_root = vim.fn.getcwd()
    vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/nvim-dap")
    write(root .. "/.vscode/launch.json", {
        '{"configurations":[{"name":"Rust debug client","type":"codelldb",',
        '"request":"launch","cwd":"${workspaceFolder}"}]}',
    })
    unchanged(base())
    vim.fn.delete(root .. "/.vscode/launch.json")
    assert(vim.fn.getcwd() == config_root, "editor cwd must not change")

    write(root .. "/services/duplicate/Cargo.toml", {
        "[package]",
        'name = "duplicate-package"',
        'version = "0.1.0"',
        'edition = "2021"',
        "[[bin]]",
        'name = "web-server"',
        'path = "src/main.rs"',
    })
    write(root .. "/services/duplicate/src/main.rs", { "fn main() {}" })
    unchanged(base())
    assert(notifications[#notifications]:match("2 matching"))
    unchanged(base("debug/missing-binary"))
    assert(notifications[#notifications]:match("0 matching"))

    metadata_result({ code = 1, stderr = "metadata failed" })
    unchanged(base())
    assert(notifications[#notifications]:match("metadata failed"))
    metadata_result({ code = 0, stdout = "invalid json" })
    unchanged(base())
    assert(notifications[#notifications]:match("invalid cargo metadata"))
    vim.system = function()
        error("cannot start cargo")
    end
    unchanged(base())
    assert(notifications[#notifications]:match("cannot start cargo"))
end, debug.traceback)

vim.notify, vim.system = original_notify, original_system
vim.fn.delete(vim.fs.dirname(root), "rf")
assert(ok, err)
print(
    "PASS: Rust DAP app selection, extra bins, new apps, profiles, manual/test/attach preservation, ambiguity and failures"
)
