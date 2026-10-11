local M = {}

local function warn(message)
    vim.notify("Cannot select Rust debug cwd: " .. message, vim.log.levels.WARN, { title = "Rust DAP" })
end

local function is_generated_launch(config)
    return config.type == "codelldb"
        and config.request == "launch"
        and type(config.name) == "string"
        and (config.name == "Rust debug client" or config.name:match("^Cargo: build%s") ~= nil)
        and vim.list_contains(config.sourceLanguages or {}, "rust")
        and type(config.cwd) == "string"
        and type(config.program) == "string"
end

-- A user may give a launch.json entry the same name as a generated config.
local function has_manual_config(config)
    local path = vim.fs.joinpath(config.cwd, ".vscode", "launch.json")
    if not vim.uv.fs_stat(path) then
        return false
    end
    local ok, entries = pcall(function()
        return require("dap.ext.vscode").getconfigs(path)
    end)
    if not ok then
        warn("cannot read launch.json; keeping the original cwd.")
        return true
    end
    for _, entry in ipairs(entries) do
        if entry.name == config.name and entry.type == config.type then
            return true
        end
    end
    return false
end

function M.enrich_config(config, on_config)
    if not is_generated_launch(config) then
        return on_config(config)
    end

    local program = vim.fs.normalize(config.program)
    -- Unit/integration tests, examples and build scripts use Cargo artifact directories.
    for _, directory in ipairs({ "deps", "examples", "build" }) do
        if vim.fs.basename(vim.fs.dirname(program)) == directory then
            return on_config(config)
        end
    end
    if has_manual_config(config) then
        return on_config(config)
    end

    local command = {
        "cargo",
        "metadata",
        "--no-deps",
        "--format-version",
        "1",
        "--locked",
        "--offline",
    }
    local ok, err = pcall(
        vim.system,
        command,
        {
            cwd = config.cwd,
            text = true,
            timeout = 10000,
        },
        vim.schedule_wrap(function(result)
            if result.code ~= 0 then
                warn(
                    vim.trim(result.stderr or "") ~= "" and vim.trim(result.stderr)
                        or ("cargo metadata exited with code " .. result.code)
                )
                return on_config(config)
            end
            local decoded, metadata = pcall(vim.json.decode, result.stdout or "")
            if
                not decoded
                or type(metadata) ~= "table"
                or type(metadata.workspace_root) ~= "string"
                or type(metadata.target_directory) ~= "string"
                or type(metadata.packages) ~= "table"
                or type(metadata.workspace_members) ~= "table"
            then
                warn("invalid cargo metadata output; keeping the original cwd.")
                return on_config(config)
            end

            -- Preserve an explicitly configured directory outside the workspace root.
            if vim.fs.normalize(config.cwd) ~= vim.fs.normalize(metadata.workspace_root) then
                return on_config(config)
            end
            local target_prefix = vim.fs.normalize(metadata.target_directory):gsub("/+$", "") .. "/"
            if program:sub(1, #target_prefix) ~= target_prefix then
                return on_config(config)
            end
            local relative = program:sub(#target_prefix + 1)
            local parts = vim.split(relative, "/", { plain = true })
            -- profile/bin or target-triple/profile/bin; exclude hashed test artifacts.
            if
                (#parts ~= 2 and #parts ~= 3)
                or vim.list_contains({ "deps", "examples", "build", "incremental" }, parts[#parts - 1])
            then
                return on_config(config)
            end

            local binary = vim.fs.basename(program):gsub("%.exe$", "")
            local members, directories = {}, {}
            for _, id in ipairs(metadata.workspace_members) do
                members[id] = true
            end
            for _, package in ipairs(metadata.packages) do
                if members[package.id] then
                    for _, target in ipairs(package.targets or {}) do
                        if target.name == binary and vim.list_contains(target.kind or {}, "bin") then
                            directories[vim.fs.dirname(package.manifest_path)] = true
                        end
                    end
                end
            end
            local candidates = vim.tbl_keys(directories)
            if #candidates ~= 1 then
                warn(("%s has %d matching workspace packages; keeping the original cwd."):format(binary, #candidates))
                return on_config(config)
            end
            local final_config = vim.deepcopy(config)
            final_config.cwd = candidates[1]
            on_config(final_config)
        end)
    )
    if not ok then
        warn(tostring(err))
        on_config(config)
    end
end

return M
