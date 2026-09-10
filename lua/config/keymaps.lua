local map = vim.keymap.set
-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

map({ "n", "v" }, "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })
map({ "n", "v" }, "<leader>qw", "<cmd>q<cr>", { desc = "Close Window" })

-- Code
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map({ "n", "v" }, "<leader>cc", vim.lsp.codelens.refresh, { desc = "Run Codelens" })
map({ "n", "v" }, "<leader>cf", function() vim.lsp.buf.format { async = true } end, { desc = "Format Document" })
map({ "n", "v" }, "<leader>cr", vim.lsp.buf.rename, { desc = "rename" })

map("n", "<c-/>", function() Snacks.terminal() end, { desc = "Terminal (cwd)" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })


-- Clear search and stop snippet on escape
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- windows
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>e", "<cmd>Neotree toggle reveal<cr>", { desc = "Neo-tree: Toggle and reveal current file" })
-- map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })
