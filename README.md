# Neovim 配置

一套基于 [lazy.nvim](https://github.com/folke/lazy.nvim) 的个人 Neovim 配置，开箱即用，内置代码补全、LSP、语法高亮、文件树、Git、调试与 AI 助手。

## 能用来做什么

- **代码编辑**：Treesitter 语法高亮、代码折叠、自动补全、代码片段、自动配对
- **语言智能（LSP）**：跳转定义、查找引用、重命名、代码操作、实时诊断
- **调试（DAP）**：断点、单步执行、变量查看，Java 与 Rust 开箱可用
- **查找与搜索**：模糊查找文件 / 内容 / 缓冲区 / 符号 / Git 历史
- **Git**：行内 blame、diff 标记、提交与分支管理
- **AI 助手**：基于 CodeCompanion，支持对话、内联改写、生成命令
- **界面**：状态栏、缩进线、通知、快捷键提示、会话恢复

## 环境要求

| 依赖 | 说明 |
| --- | --- |
| Neovim | >= 0.11（使用 `vim.lsp.enable` 等新 API，推荐最新稳定版） |
| git | 用于插件管理与 GitHub 相关功能 |
| ripgrep (`rg`) | 模糊搜索内容（picker grep） |
| Nerd Font | 图标正常显示，推荐 `Maple Mono NF` |
| 剪贴板工具 | Linux 下需 `xclip` / `wl-clipboard`，系统剪贴板才能生效 |
| Node.js / npm | 部分 LSP 与工具依赖（如 Copilot 补全） |

> 首次启动会自动克隆 lazy.nvim 并安装所有插件，请保持网络畅通。

## 安装与启动

1. 备份已有配置（如果存在）：

   ```bash
   mv ~/.config/nvim ~/.config/nvim.bak
   ```

2. 克隆本仓库：

   ```bash
   git clone git@github.com:1paridis/nvim.git ~/.config/nvim
   ```

3. 启动 Neovim：

   ```bash
   nvim
   ```

   首次启动会自动安装 lazy.nvim、插件，以及 Mason 中声明的 LSP / 调试器，等待安装完成即可。

4. 之后可用 `:Lazy sync` 手动同步插件，用 `:Mason` 管理语言服务器。

## 快速上手

- **Leader 键**：`<Space>`（空格），局部 Leader 为 `\`
- 不确定某个键有什么用，按 `<Space>` 后等待，会弹出 which-key 提示菜单
- 常用入口：
  - `<Space>e`：打开 / 关闭文件树（neo-tree）
  - `<Space><Space>`：智能查找文件
  - `<Space>/`：全局搜索内容（grep）
  - `Ctrl + /`：打开 / 关闭终端
  - `gd`：跳转定义，`gr`：查找引用
  - `<Space>ac`：打开 AI 对话窗口

## 语言支持

已针对以下语言做了开箱配置：

- **Java**：通过 `nvim-jdtls` 接入，自动识别 Maven / Gradle 项目，按项目隔离 workspace，支持 Lombok、源码跳转与 DAP 调试（`java-debug-adapter`）
- **Rust**：通过 `rustaceanvim` 接入 rust-analyzer，`Cargo.toml` 由 `crates.nvim` 提供补全与版本管理，调试使用 `codelldb`
- **Lua**：通过 `lua-language-server` 支持，并使用 `stylua` 格式化

其他语言的服务器可在 `lua/plugins/mason.lua` 的 `ensure_installed` 中取消注释后安装。

## AI 助手（CodeCompanion）

配置默认接入火山方舟（vol）适配器。API Key 从 `lua/config/secrets.lua` 读取（该文件已被 `.gitignore` 忽略，不会提交），格式如下：

```lua
-- lua/config/secrets.lua
return {
  ark_api_key = "你的 API Key",
}
```

也可改用环境变量 `ARK_API_KEY`。默认模型为 `deepseek-v4-flash-ga-260731`，其余可选模型见 `lua/plugins/codecompanion.lua`。

