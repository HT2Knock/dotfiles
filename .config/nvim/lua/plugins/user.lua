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
    "leath-dub/snipe.nvim",
    opts = {},
    keys = {
      {
        "<leader>bb",
        function()
          require("snipe").open_buffer_menu()
        end,
        desc = "Open Snipe buffer menu",
      },
    },
  },
}
