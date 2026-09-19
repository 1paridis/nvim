-- Requires installed plugins/parsers. Run: nvim --headless -u NONE -i NONE -l tests/autotag.lua
local data = vim.fn.stdpath("data")
for _, name in ipairs({ "nvim-treesitter", "nvim-ts-autotag" }) do
    vim.opt.rtp:append(data .. "/lazy/" .. name)
end
vim.cmd("runtime! plugin/*.lua")
vim.cmd("filetype plugin indent on")
require("nvim-ts-autotag").setup(dofile("lua/plugins/autotag.lua").opts)

local function input(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "xt", false)
end

local cases = {
    { "html", '<div class="box">hello</div>', '<section class="box">hello</section>' },
    { "vue", '<template><div class="box">hello</div></template>', '<template><section class="box">hello</section></template>' },
    { "javascriptreact", 'const App = () => <div className="box">hello</div>', 'const App = () => <section className="box">hello</section>' },
    { "typescriptreact", 'const App = () => <div className="box">hello</div>', 'const App = () => <section className="box">hello</section>' },
}
for _, case in ipairs(cases) do
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { case[2] })
    vim.bo[buf].filetype = case[1]
    vim.treesitter.start(buf)
    local position = assert(case[2]:find("div", 1, true))
    vim.api.nvim_win_set_cursor(0, { 1, position - 1 })
    input("ciwsection<Esc>")
    local actual = vim.api.nvim_get_current_line()
    assert(actual == case[3], case[1] .. " rename failed: " .. actual)
    print("PASS: " .. case[1] .. " rename preserves attributes and updates closing tag")
end

local buf = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(buf)
vim.bo[buf].filetype = "html"
vim.treesitter.start(buf)
input("i<div><Esc>")
assert(vim.api.nvim_get_current_line() == "<div></div>", "Auto close failed")
print("PASS: HTML automatic closing tag")
