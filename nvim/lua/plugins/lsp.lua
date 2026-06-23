return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.diagnostic.config({
        update_in_insert = false,
        virtual_text = { prefix = "●" },
        severity_sort = true,
        float = {
          border = "rounded",
          source = true,
        },
      })

      -- nixpkgs でインストールした LSP サーバーを直接設定
      vim.lsp.config("ts_ls", {})
      vim.lsp.config("eslint", {})
      vim.lsp.config("pyright", {})

      vim.lsp.enable("ts_ls")
      vim.lsp.enable("eslint")
      vim.lsp.enable("pyright")

      -- 全 LSP に共通のキーマップ
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
          end

          map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
          map("n", "gr", vim.lsp.buf.references, "Go to References")
          map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
          map("n", "gt", vim.lsp.buf.type_definition, "Go to Type Definition")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
          map("n", "<leader>la", vim.lsp.buf.code_action, "Code Action")
          map("v", "<leader>la", vim.lsp.buf.code_action, "Code Action")
          map("n", "<leader>lr", vim.lsp.buf.rename, "Rename")
          map("n", "<leader>ld", vim.diagnostic.open_float, "Line Diagnostics")
          map("n", "<leader>lq", vim.diagnostic.setloclist, "Quickfix Diagnostics")
          map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next Diagnostic")
          map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev Diagnostic")
          map("n", "]e", function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true }) end, "Next Error")
          map("n", "[e", function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true }) end, "Prev Error")

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
