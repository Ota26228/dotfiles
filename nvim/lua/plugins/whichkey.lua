return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    wk.setup({
      preset = "modern",
      delay = 300,
    })
    wk.add({
      { "<leader>b", group = "Buffer" },
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Git" },
      { "<leader>l", group = "LSP" },
      { "<leader>r", group = "Rust" },
      { "<leader>t", group = "Terminal" },
      { "<leader>x", group = "Trouble" },
    })
  end,
}
