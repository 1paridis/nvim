local ok, secrets = pcall(require, "config.secrets")
secrets = ok and secrets or {}

local ooioo_api_key = secrets.ooioo_api_key or vim.env.OOIOO_API_KEY
local deepseek_api_key = secrets.deepseek_api_key or vim.env.DEEPSEEK_API_KEY

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    adapters = {
      http = {
        deepseek = function()
          return require("codecompanion.adapters").extend("deepseek", {
            env = {
              api_key = deepseek_api_key,
            },
            schema = {
              model = {
                -- canonical id from https://api.deepseek.com/models
                default = "deepseek-flash",
              },
            },
          })
        end,
        ooioo = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            name = "ooioo",
            formatted_name = "ooioo GPT 5.6 Sol",
            env = {
              url = "https://ooioo.work/v1",
              chat_url = "/chat/completions",
              api_key = ooioo_api_key,
            },
            schema = {
              model = {
                default = "gpt-5.6-sol",
                choices = {
                  ["gpt-5.6-sol"] = { formatted_name = "GPT 5.6 Sol" },
                },
              },
            },
          })
        end,
      }
    },
    interactions = {
      chat = { adapter = "deepseek" },
      inline = { adapter = "deepseek" },
      cmd = { adapter = "deepseek" },
      background = { adapter = "deepseek" },
    },
  },
  keys = {
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>",     desc = "Action Palette", mode = { "n", "v" } },
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Chat",    mode = { "n", "v" } },
    { "<leader>ai", "<cmd>CodeCompanion<cr>",            desc = "Inline Prompt",  mode = { "n", "v" } },
    { "<leader>am", function()
      vim.ui.input({ prompt = "CodeCompanion command: " }, function(input)
        if input and input ~= "" then
          vim.cmd("CodeCompanionCmd " .. input)
        end
      end)
    end, desc = "Generate Command" },
    { "ga",         "<cmd>CodeCompanionChat Add<cr>",    desc = "Add to Chat",    mode = "v" },
  },
}
