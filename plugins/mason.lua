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
          "gopls",
        },
        automatic_installation = true,
        run_on_start = true,

        handlers = {
          -- attach installed LSP's to buffers
          function(server_name)
            require("lspconfig")[server_name].setup {
              -- filetypes = { "php" },
              -- root_dir = require("lspconfig.util").root_pattern("composer.json", ".git"),
            }
          end,
        },
      }
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    config = function()
      require("mason-null-ls").setup {
        ensure_installed = { 
          "stylua", 
          "prettier",
          "gofumpt",
          "goimports-reviser",
          "golines",
        },
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
