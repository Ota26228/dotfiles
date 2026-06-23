return {
  {
    -- 新 nvim-treesitter (v1.x): require("nvim-treesitter.configs") は廃止
    -- lazy loading 非対応のため lazy = false が必要
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- NixOS では parsers を nix 経由でインストールしてください
      -- home.packages に vimPlugins.nvim-treesitter.withAllGrammars を追加するか、
      -- :TSInstall <language> (要 C コンパイラ) を使用してください
      require("nvim-treesitter").setup({})
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
          },
        },
      })
    end,
  },
}
