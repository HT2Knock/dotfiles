return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      style = 'night',
      styles = {
        sidebars = 'normal',
        floats = 'normal',
      },
      on_highlights = function(hl, c)
        hl.DapStoppedLine = {
          bg = '#2d3f76',
        }
      end,
    },
  },
}
