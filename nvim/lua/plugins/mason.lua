return {
  -- Mason本体と、LSP/フォーマッタを自動インストールするための設定
  {
    "williamboman/mason.nvim",
    cmd = "Mason", -- :Mason コマンドを有効化
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "vtsls",        -- TypeScript/React LSP
        "eslint-lsp",   -- タイポ・静的解析
        "prettier",     -- コード整形
      },
    },
  },
  -- Masonとlspconfigを橋渡しする設定
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      automatic_installation = true,
    },
  },
}
