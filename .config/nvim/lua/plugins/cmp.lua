return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    {
      "supermaven-inc/supermaven-nvim",
      opts = {
        keymaps = {
          accept_suggestion = "<C-f>",
          clear_suggestion = "<Nop>",
          accept_word = "<C-w>",
        },
        log_level = "warn",
        disable_inline_completion = true, -- disables inline completion for use with cmp
        disable_keymaps = false, -- disables built in keymaps for more manual control
        ignore_filetypes = { markdown = true },
      },
      config = function(_, opts) require("supermaven-nvim").setup(opts) end,
    },
  },
  opts = function(_, opts)
    opts.formatting.format = require("lspkind").cmp_format {
      symbol_map = {
        Supermaven = "",
      },
    }

    local cmp = require "cmp"
    opts.sources = cmp.config.sources {
      { name = "supermaven" },
      { name = "nvim_lsp", priority = 750 },
      { name = "luasnip", priority = 725 },
      { name = "buffer", priority = 500 },
      { name = "path", priority = 250 },
    }
    return opts
  end,
}
