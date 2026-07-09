return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = true,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          sidebars = "transparent",
          floats = "transparent",
        },
        on_colors = function(colors)
          colors.bg = "#000000"
          colors.bg_dark = "#000000"
          colors.bg_float = "#05150a"
          colors.bg_highlight = "#0a2512"
          colors.bg_popup = "#05150a"
          colors.bg_search = "#00441b"
          colors.bg_sidebar = "#000000"
          colors.bg_statusline = "#05150a"
          colors.bg_visual = "#0a3518"
          colors.border = "#00ff66"
          colors.fg = "#00ff66"
          colors.fg_dark = "#00cc55"
          colors.fg_float = "#00ff66"
          colors.fg_gutter = "#00441b"
          colors.fg_sidebar = "#00cc55"
          
          -- syntax colors
          colors.red = "#39ff14"
          colors.orange = "#a6ff00"
          colors.yellow = "#d4ff7f"
          colors.green = "#00ff66"
          colors.teal = "#00ffd5"
          colors.blue = "#00ffaa"
          colors.purple = "#39ff14"
          colors.magenta = "#00cc55"
          colors.cyan = "#00ffaa"
          colors.comment = "#00441b"
          
          -- diagnostics
          colors.error = "#39ff14"
          colors.warning = "#a6ff00"
          colors.info = "#00ff66"
          colors.hint = "#00ffd5"
        end,
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}
