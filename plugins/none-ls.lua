-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    -- opts variable is the default configuration table for the setup function call
    -- local null_ls = require "null-ls"

    -- Check supported formatters and linters
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics

    -- Only insert new sources, do not replace the existing ones
    -- (If you wish to replace, use `opts.sources = {}` instead of the `list_insert_unique` function)
    local null_ls = require "null-ls"
    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      -- Lua formatter
      null_ls.builtins.formatting.stylua,
      
      -- Go formatters
      null_ls.builtins.formatting.gofumpt,      -- Enhanced gofmt
      null_ls.builtins.formatting.goimports_reviser, -- Import organizer
      null_ls.builtins.formatting.golines,     -- Line length formatter
      
      -- Web formatters
      -- null_ls.builtins.formatting.prettier,
    })
  end,
}
