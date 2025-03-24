return {
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
  { "folke/persistence.nvim", enabled = false },
  { "akinsho/bufferline.nvim", enabled = false },
  {
    "stevearc/oil.nvim",
    opts = {},
    dependencies = {
      {
        "echasnovski/mini.icons",
        opts = {
          default_file_epxlorer = true,
          view_options = {
            show_hidden = true,
          },
        },
      },
    },
    lazy = false,
  },
}
