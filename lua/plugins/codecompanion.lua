local ok, secrets = pcall(require, "config.secrets")
local ark_api_key = (ok and secrets.ark_api_key) or vim.env.ARK_API_KEY

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    adapters = {
      http = {
        vol = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            name = "vol",
            formatted_name = "火山方舟 vol",
            env = {
              url = "https://ark.cn-beijing.volces.com/api/coding/v3",
              chat_url = "/chat/completions",
              api_key = ark_api_key,
            },
            schema = {
              model = {
                default = "deepseek-v4-flash-ga-260731",
                choices = {
                  ["deepseek-v4-flash-ga-260731"] = { formatted_name = "DeepSeek V4 Flash" },
                  ["deepseek-v4-pro-ga-260813"]  = { formatted_name = "DeepSeek V4 Pro" },
                  ["glm-5.3"]                    = { formatted_name = "GLM 5.3" },
                },
              },
            },
          })
        end,
      },
    },
    interactions = {
      chat = { adapter = "vol" },
      inline = { adapter = "vol" },
      cmd = { adapter = "vol" },
      background = { adapter = "vol" },
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
