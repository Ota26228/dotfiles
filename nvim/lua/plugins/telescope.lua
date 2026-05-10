return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "truncate" },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-c>"] = actions.close,
            ["<CR>"] = actions.select_default,
          },
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })

    -- fzf拡張を読み込む
    telescope.load_extension("fzf")

    -- キーマップ
    local keymap = vim.keymap
    keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "ファイル検索" })
    keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "テキスト検索" })
    keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "バッファ検索" })
    keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "ヘルプ検索" })
    keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "最近使ったファイル" })
  end,
}