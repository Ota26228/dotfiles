return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
    opts = {
      server = {
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "K", function()
            vim.cmd.RustLsp({ "hover", "actions" })
          end, { buffer = bufnr, desc = "Hover Actions" })

          vim.keymap.set("n", "<leader>ca", function()
            vim.cmd.RustLsp("codeAction")
          end, { buffer = bufnr, desc = "Code Action" })

          vim.keymap.set("n", "<leader>rr", function()
            vim.cmd.RustLsp("runnables")
          end, { buffer = bufnr, desc = "Runnables" })

          vim.keymap.set("n", "<leader>rt", function()
            vim.cmd.RustLsp("testables")
          end, { buffer = bufnr, desc = "Testables" })

          vim.keymap.set("n", "<leader>re", function()
            vim.cmd.RustLsp("expandMacro")
          end, { buffer = bufnr, desc = "Expand Macro" })

          vim.keymap.set("n", "<leader>rE", function()
            vim.cmd.RustLsp("explainError")
          end, { buffer = bufnr, desc = "Explain Error" })

          vim.keymap.set("n", "<leader>rD", function()
            vim.cmd.RustLsp("openDocs")
          end, { buffer = bufnr, desc = "Open Docs (docs.rs)" })
        end,
        default_settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
          },
        },
      },
    },
    config = function(_, opts)
      vim.g.rustaceanvim = opts
    end,
  },

  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        blink = { enabled = true },
      },
    },
  },
}
