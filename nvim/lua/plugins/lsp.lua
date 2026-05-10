return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- 1. 診断表示の設定
      vim.diagnostic.config({
        update_in_insert = false,
        virtual_text = { prefix = "●" },
        severity_sort = true,
      })

      -- 2. mason-lspconfig のセットアップ
      require("mason-lspconfig").setup({
        ensure_installed = { "vtsls", "eslint" },
      })

      -- 3. vim.lsp.config を使った最新のセットアップ
      -- 注意: これにより lspconfig.vtsls.setup() のような古い形式を回避します

      -- vtsls (TypeScript/React)
      vim.lsp.config("vtsls", {})

      -- eslint
      vim.lsp.config("eslint", {
        -- on_attach の代わりに、LSPがバッファにアタッチされた時の処理
        -- Neovim 0.11以降は LspAttach オートコマンドで書くのがモダンです
      })

      -- 最後に、全てを有効化
      vim.lsp.enable("vtsls")
      vim.lsp.enable("eslint")

      -- ESLintの自動保存修正をオートコマンドで別途定義
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "eslint" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              command = "EslintFixAll",
            })
          end
        end,
      })
    end,
  },
}
