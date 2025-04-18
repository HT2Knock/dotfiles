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
}
