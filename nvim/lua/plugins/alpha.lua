return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- ヘッダー（アスキーアート）
    dashboard.section.header.val = {
      "                                   ",
      "   ███╗   ██╗██╗   ██╗██╗███╗   ███╗",
      "   ████╗  ██║██║   ██║██║████╗ ████║",
      "   ██╔██╗ ██║██║   ██║██║██╔████╔██║",
      "   ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
      "   ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
      "   ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
      "                                   ",
    }

    -- ボタン
    dashboard.section.buttons.val = {
      dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
      dashboard.button("n", "  New file", "<cmd>ene <BAR> startinsert<CR>"),
      dashboard.button("r", "  Recent", "<cmd>Telescope oldfiles<CR>"),
      dashboard.button("g", "  Find text", "<cmd>Telescope live_grep<CR>"),
      dashboard.button("c", "  Config", "<cmd>e ~/.config/nvim/init.lua<CR>"),
      dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
    }

    -- フッター
    dashboard.section.footer.val = "🚀 Neovim"

    -- セットアップ
    alpha.setup(dashboard.opts)
  end,
}