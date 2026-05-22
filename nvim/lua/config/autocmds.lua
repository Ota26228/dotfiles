local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ヤンク時にハイライト
autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- 最後のカーソル位置を復元
autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- 保存時に末尾の空白を削除
autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

local ime_group = augroup("Fcitx5Ime", { clear = true })
local ime_was_active = false
local fcitx5_remote = vim.fn.executable("fcitx5-remote") == 1 and "fcitx5-remote" or nil

local function fcitx5(args)
  if not fcitx5_remote then
    return nil
  end

  local result = vim.system(vim.list_extend({ fcitx5_remote }, args), { text = true }):wait()
  if result.code ~= 0 then
    return nil
  end

  return vim.trim(result.stdout or "")
end

autocmd("InsertLeave", {
  group = ime_group,
  callback = function()
    ime_was_active = fcitx5({}) == "2"
    fcitx5({ "-c" })
  end,
})

autocmd("InsertEnter", {
  group = ime_group,
  callback = function()
    if ime_was_active then
      fcitx5({ "-o" })
    end
  end,
})
