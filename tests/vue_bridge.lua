-- Run from the config directory: nvim --headless -u NONE -i NONE -l tests/vue_bridge.lua
local bridge = dofile("lua/config/vue.lua")
local original = {
    get_clients = vim.lsp.get_clients,
    defer_fn = vim.defer_fn,
    notify = vim.notify,
}
local queue, notifications, calls, replies
local ready, stopped, failure, empty_response
local ts = {
    exec_cmd = function(_, command, context, callback)
        calls[#calls + 1] = { command = command, context = context }
        if failure then
            callback({ message = "test error" }, nil)
        elseif empty_response then
            callback(nil, nil)
        else
            callback(nil, { body = { ok = true } })
        end
    end,
}
vim.lsp.get_clients = function(opts)
    assert(opts.name == "vtsls" and opts.bufnr == 7)
    return ready and { ts } or {}
end
vim.defer_fn = function(callback, delay)
    assert(delay == 100)
    queue[#queue + 1] = callback
end
vim.notify = function(message)
    notifications[#notifications + 1] = message
end

local function reset()
    queue, notifications, calls, replies = {}, {}, {}, {}
    ready, stopped, failure, empty_response = true, false, false, false
    local client = {
        handlers = {},
        is_stopped = function() return stopped end,
        notify = function(_, method, params)
            assert(method == "tsserver/response")
            replies[#replies + 1] = params
        end,
    }
    bridge.on_init(client)
    return function(request)
        client.handlers["tsserver/request"](nil, request, { bufnr = 7 })
    end
end

local function drain()
    local count = 0
    while #queue > 0 do
        count = count + 1
        assert(count <= 30, "retry loop did not terminate")
        table.remove(queue, 1)()
    end
    return count
end

local ok, err = xpcall(function()
    for _, nested in ipairs({ false, true }) do
        local handle = reset()
        local request = { 42, "_vue:projectInfo", { file = "/tmp/App.vue" } }
        handle(nested and { request } or request)
        assert(#calls == 1 and #replies == 1)
        assert(calls[1].command.command == "typescript.tsserverRequest")
        assert(vim.deep_equal(calls[1].command.arguments, { request[2], request[3] }))
        assert(calls[1].context.bufnr == 7)
        local expected = { 42, { ok = true } }
        assert(vim.deep_equal(replies[1], nested and { expected } or expected))
    end

    local handle = reset()
    failure = true
    handle({ 1, "test", {} })
    assert(replies[1][1] == 1 and replies[1][2] == vim.NIL)
    assert(#notifications == 1)

    handle = reset()
    empty_response = true
    handle({ { 7, "test", {} } })
    assert(replies[1][1][1] == 7 and replies[1][1][2] == vim.NIL)

    handle = reset()
    ready = false
    handle({ 2, "test", {} })
    assert(#calls == 0 and #queue == 1)
    ready = true
    assert(drain() == 1 and #calls == 1 and #replies == 1)

    handle = reset()
    ready = false
    handle({ 3, "test", {} })
    assert(drain() == 10 and #calls == 0 and #notifications == 1)
    assert(replies[1][2] == vim.NIL)
    -- A later request gets its own retry budget.
    handle({ 4, "test", {} })
    assert(#queue == 1)
    ready = true
    drain()
    assert(#calls == 1 and replies[2][1] == 4)

    handle = reset()
    stopped = true
    handle({ 5, "test", {} })
    assert(#calls == 0 and #queue == 0 and #replies == 0)

    handle = reset()
    ready = false
    handle({ 6, "test", {} })
    stopped = true
    drain()
    assert(#calls == 0 and #replies == 0 and #notifications == 0)
end, debug.traceback)

vim.lsp.get_clients = original.get_clients
vim.defer_fn = original.defer_fn
vim.notify = original.notify
assert(ok, err)
print("PASS: Vue flat/nested protocol, errors, retry recovery/limit, stopped clients")
