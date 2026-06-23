return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",
        separator_style = "slant",
        always_show_bufferline = false,
        show_buffer_close_icons = true,
        show_close_icon = false,
        color_icons = true,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
          local icons = { error = " ", warning = " ", info = " " }
          local ret = ""
          for sev, icon in pairs(icons) do
            if diag[sev] and diag[sev] > 0 then
              ret = ret .. icon .. diag[sev]
            end
          end
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "oil",
            text = "File Explorer",
            highlight = "Directory",
            separator = true,
          },
        },
      },
    })

    local map = vim.keymap.set
    map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev Buffer" })
    map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
    map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete Buffer" })
    map("n", "<leader>bD", "<cmd>BufferLineCloseOthers<CR>", { desc = "Delete Other Buffers" })
    map("n", "<leader>bp", "<cmd>BufferLinePick<CR>", { desc = "Pick Buffer" })
  end,
}
