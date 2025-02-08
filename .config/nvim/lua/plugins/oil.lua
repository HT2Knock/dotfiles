return {
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    opts = {
      default_file_epxlorer = true,
      view_options = {
        show_hidden = true,
      },
    },
  },
}
