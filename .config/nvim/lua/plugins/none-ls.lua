if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE
-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  opts = function(_, config)
    local null_ls = require "null-ls"
    config.sources = {
      null_ls.setup {
        sources = {},
      },
    }
    return config
  end,
}
