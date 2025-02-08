return {
  "leath-dub/snipe.nvim",
  opts = {},
  keys = {
    {
      "<leader>b",
      function() require("snipe").open_buffer_menu() end,
      desc = "Open Snipe buffer menu",
    },
  },
}
