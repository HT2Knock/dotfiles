return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      style = "night",
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  { "folke/flash.nvim", enabled = false },
  {
    "stevearc/oil.nvim",
    opts = {
      default_file_epxlorer = true,
      view_options = {
        show_hidden = true,
      },
    },
    dependencies = { { "echasnovski/mini.icons" } },
    lazy = false,
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Oil" },
    },
  },
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.completion = opts.completion or {}
      opts.completion.list = opts.completion.list or {}
      opts.completion.list.selection = {
        preselect = true,
        auto_insert = true,
      }
      return opts
    end,
  },
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      max_count = 5,
    },
  },
}
