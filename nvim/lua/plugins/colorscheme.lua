return {
  "ellisonleao/gruvbox.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("gruvbox").setup()
    vim.cmd([[colorscheme gruvbox]])
  end,
}
