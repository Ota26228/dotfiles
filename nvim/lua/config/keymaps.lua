local keymap = vim.keymap

-- 保存・終了
keymap.set("n", "<leader>w", "<cmd>w<CR>")
keymap.set("n", "<leader>q", "<cmd>q<CR>")

-- ウィンドウ移動
keymap.set("n", "<C-h>", "<C-w>h")
keymap.set("n", "<C-j>", "<C-w>j")
keymap.set("n", "<C-k>", "<C-w>k")
keymap.set("n", "<C-l>", "<C-w>l")

-- バッファ移動
keymap.set("n", "<S-h>", "<cmd>bprevious<CR>")
keymap.set("n", "<S-l>", "<cmd>bnext<CR>")

-- インデント（ビジュアルモードで連続適用）
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- 検索ハイライトを消す
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
