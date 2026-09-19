local M = {}

function M.on_init(client)
    client.handlers["tsserver/request"] = function(_, result, context)
        -- 旧版为 {{ id, command, payload }}，新版为 { id, command, payload }。
        local nested = type(result[1]) == "table"
        local request = nested and result[1] or result
        local id, command, payload = unpack(request)
        local retries = 0

        local function respond(body)
            if client:is_stopped() then
                return
            end
            local response = { id, body or vim.NIL }
            client:notify("tsserver/response", nested and { response } or response)
        end

        local function forward()
            if client:is_stopped() then
                return
            end
            local ts_client = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })[1]
            if not ts_client then
                -- Vue 可能先于 vtsls 就绪；重试次数按请求计数。
                if retries < 10 then
                    retries = retries + 1
                    vim.defer_fn(forward, 100)
                else
                    vim.notify("vue_ls: 未找到 vtsls，请检查 :LspInfo", vim.log.levels.ERROR)
                    respond(nil)
                end
                return
            end

            ts_client:exec_cmd({
                title = "vue_request_forward",
                command = "typescript.tsserverRequest",
                arguments = { command, payload },
            }, { bufnr = context.bufnr }, function(err, response)
                if err then
                    vim.notify("vue_ls: TypeScript 转发失败: " .. (err.message or vim.inspect(err)), vim.log.levels.WARN)
                end
                respond(response and response.body)
            end)
        end

        forward()
    end
end

return M
