-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup {
        ensure_installed = {
          "lua_ls",
          "phpactor",
          "ts_ls",
          "pyright",
        },
        automatic_installation = true,
        run_on_start = true,
      }
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    config = function()
      require("mason-null-ls").setup {
        ensure_installed = { "stylua", "prettier" },
        automatic_installation = true,
        run_on_start = true,
      }
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    config = function()
      require("mason-nvim-dap").setup {
        ensure_installed = {},
        automatic_installation = true,
        run_on_start = true,
      }
    end,
  },
}
