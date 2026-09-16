-- Terminate a session, then make sure the debuggee actually dies.
--
-- With `console = "integratedTerminal"` (nvim-jdtls default) java-debug starts
-- the JVM through nvim-dap's `runInTerminal` reverse request, so nvim owns the
-- process and the adapter's `terminateDebuggee` cannot kill it. Stopping the
-- terminal job closes that gap; for adapters that own the process (codelldb,
-- internalConsole) `term_buf` is nil and this is a no-op.
local function kill_debuggee_terminal(session)
  local term_buf = session and session.term_buf
  if not (term_buf and vim.api.nvim_buf_is_valid(term_buf)) then
    return
  end
  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(term_buf) then
      local job = vim.b[term_buf].terminal_job_id
      if job and job > 0 then
        pcall(vim.fn.jobstop, job)
      end
    end
  end, 300)
end

local function force_terminate()
  require("dap").terminate({ disconnect_args = { terminateDebuggee = true } })
end

return {
  {
    "mfussenegger/nvim-dap",
    desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",

    -- stylua: ignore
    keys = {
      { "<F5>",       function() require("dap").continue() end,                                             desc = "Run/Continue" },
      { "<leader>da", function() require("dap").continue({ before = get_args }) end,                        desc = "Run with Args" },
      { "<leader>dc", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end,                                                desc = "Go to Line (No Execute)" },
      { "<F7>",       function() require("dap").step_into() end,                                            desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end,                                                 desc = "Down" },
      { "<leader>dk", function() require("dap").up() end,                                                   desc = "Up" },
      { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Run Last" },
      { "<S-F8>",     function() require("dap").step_out() end,                                             desc = "Step Out" },
      { "<F8>",       function() require("dap").step_over() end,                                            desc = "Step Over" },
      { "<leader>dP", function() require("dap").pause() end,                                                desc = "Pause" },
      { "<leader>ds", function() require("dap").session() end,                                              desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
    },

    config = function()
      local dap = require("dap")
      -- highlight when stopped on a line (bright yellow bg, dark text)
      local cp = require("catppuccin.palettes").get_palette("mocha")
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, fg = cp.base, bg = cp.yellow })

      -- setup dap config by VsCode launch.json file
      local vscode = require("dap.ext.vscode")
      local json = require("plenary.json")
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end

      -- dap.configurations.java = {
      --   {
      --     type = "java",
      --     request = "attach",
      --     name = "Debug (Attach) - Remote",
      --     hostName = "127.0.0.1",
      --     port = 5005,
      --   },
      -- }
      vim.fn.sign_define("DapStopped",
        { text = "󰁕 ", texthl = "DiagnosticWarn", linehl = "DapStoppedLine", numhl = "DapStoppedLine" })
      vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapBreakpointCondition", { text = " ", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapBreakpointRejected", { text = " ", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapLogPoint", { text = ".>", texthl = "DiagnosticInfo" })
    end,
  },

  -- Persist breakpoints to disk so they survive restarts.
  -- `always_reload` is required because persistence.nvim restores buffers via a
  -- session; without it breakpoints are not re-applied on startup.
  {
    "Weissle/persistent-breakpoints.nvim",
    dependencies = { "mfussenegger/nvim-dap" },
    event = { "BufReadPre", "BufNewFile" },
    -- stylua: ignore
    keys = {
      { "<leader>db", function() require("persistent-breakpoints.api").toggle_breakpoint() end,           desc = "Toggle Breakpoint" },
      { "<leader>dB", function() require("persistent-breakpoints.api").set_conditional_breakpoint() end, desc = "Breakpoint Condition" },
    },
    config = function()
      require("persistent-breakpoints").setup({
        load_breakpoints_event = { "BufReadPost" },
        always_reload = true,
      })
    end,
  },

  -- IDEA-style tabbed debug UI (bottom panel with switchable sections)
  {
    "igorlfs/nvim-dap-view",
    version = "1.*",
    dependencies = { "mfussenegger/nvim-dap" },
    -- Load eagerly so its listeners/auto_toggle and terminal handling are
    -- registered before a session is started via any nvim-dap key.
    event = "VeryLazy",
    -- stylua: ignore
    keys = {
      { "<leader>du", function() require("dap-view").toggle() end,   desc = "Dap UI" },
      { "<leader>de", function() require("dap-view").hover() end,    desc = "Eval", mode = { "n", "v" } },
      { "<leader>dw", function() require("dap-view").add_expr() end, desc = "Watch Expression" },
      { "<leader>dT", force_terminate, desc = "Terminate (kill debuggee)" },
    },
    opts = {
      winbar = {
        -- Bottom "tabs"; order shown in the winbar.
        -- "console" merges the program terminal into the same window.
        sections = { "threads", "scopes", "watches", "breakpoints", "exceptions", "console" },
        default_section = "console", -- open on the Console tab when a session starts
        show_keymap_hints = true,
        controls = {
          enabled = true,
          position = "right",
          -- No "disconnect": it only detaches and leaves the JVM running.
          buttons = { "play", "step_into", "step_over", "step_out", "step_back", "run_last", "terminate" },
        },
      },
      windows = {
        size = 15, -- absolute height (> 1) of the bottom panel
        position = "below",
      },
      virtual_text = {
        enabled = true, -- replaces nvim-dap-virtual-text
        -- IDEA-style: render `name = value` at end of line instead of splicing
        -- the raw value into the middle of the code (inline).
        position = "eol",
        format = function(variable)
          local value = tostring(variable.value or ""):gsub("%s+", " ")
          if #value > 60 then
            value = value:sub(1, 60) .. "…"
          end
          return " " .. value
        end,
      },
      auto_toggle = true, -- open on session start, close when the session ends
      follow_tab = true,
    },
    config = function(_, opts)
      require("dap-view").setup(opts)

      -- Make every new session reopen on `default_section` (console), even if
      -- the user switched tabs during the previous session.
      local dap = require("dap")
      local dv_state = require("dap-view.state")
      for _, event in ipairs({ "event_terminated", "disconnect" }) do
        dap.listeners.before[event]["dap_view_console_default"] = function()
          dv_state.current_section = nil
        end
        dap.listeners.after[event]["dap_kill_debuggee_terminal"] = function(session)
          kill_debuggee_terminal(session)
        end
      end

      -- Object value popup. Java Maps/collections are shown by the adapter as
      -- `Type@id size=N`; evaluating `String.valueOf(expr)` yields the real
      -- value (e.g. `{9=1, ...}`) which we render in dap-view's hover float.
      local function expr_at_cursor()
        local line = vim.api.nvim_win_get_cursor(0)[1]
        local section = dv_state.current_section

        if section == "scopes" then
          local path = dv_state.line_to_variable_path[line]
          return path and dv_state.variable_path_to_evaluate_name[path]
        elseif section == "watches" then
          local expression = dv_state.expression_views_by_line[line]
          if expression then
            return expression.expression
          end
          local variable = dv_state.variable_views_by_line[line]
          return variable and variable.view.variable.evaluateName
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dap-view",
        callback = function(args)
          vim.keymap.set("n", "<leader>dv", function()
            local expr = expr_at_cursor()
            if not expr then
              vim.notify("No variable under cursor", vim.log.levels.WARN)
              return
            end
            require("dap-view").hover(("String.valueOf(%s)"):format(expr), true)
          end, { buffer = args.buf, desc = "Object Value (popup)" })
        end,
      })

      -- REPL as a floating popup
      local repl_win
      vim.api.nvim_create_user_command("DapViewFloatRepl", function()
        local width = math.min(120, math.floor(vim.o.columns * 0.8))
        local height = math.min(30, math.floor(vim.o.lines * 0.4))
        local buf = vim.api.nvim_create_buf(false, true)
        repl_win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = math.floor((vim.o.lines - height) / 2),
          col = math.floor((vim.o.columns - width) / 2),
          border = "rounded",
          title = "DAP REPL",
          title_pos = "center",
        })
        vim.api.nvim_set_current_win(repl_win)
      end, {})

      vim.keymap.set("n", "<leader>dr", function()
        require("dap").repl.toggle({}, "DapViewFloatRepl")
        if repl_win and vim.api.nvim_win_is_valid(repl_win) then
          vim.api.nvim_set_current_win(repl_win)
          vim.cmd.startinsert()
        end
      end, { desc = "DAP REPL (Float)" })
    end,
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = {
      adapters = {
        ["rustaceanvim.neotest"] = {},
      },
    },
  },
}
