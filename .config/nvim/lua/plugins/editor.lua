return {
  {
    'Bekaboo/dropbar.nvim',
    opts = {},
  },
  {
    'MagicDuck/grug-far.nvim',
    opts = {},
  },
  { 'NMAC427/guess-indent.nvim', event = 'BufReadPost', opts = {} },
  {
    'catgoose/nvim-colorizer.lua',
    event = 'BufReadPre',
    opts = {
      user_default_options = {
        css = true,
        css_fn = true,
        tailwind = true,
      },
    },
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'helix',
      spec = {
        { '<leader>s', group = '[S]earch', icon = '󱙓' },
        { '<leader>t', group = '[T]oggle', icon = '' },
        { '<leader>f', group = '[F]ind', icon = '󰈞' },
        { '<leader>g', group = '[G]it', icon = '' },
        { '<leader>h', group = '[H]unk', icon = '' },
        { '<leader>c', group = '[C]ode', icon = '' },
        { '<leader>n', group = '[N]otes', icon = '' },
        { '<leader>m', group = 'Debug [M]aster', icon = '󰃤' },
        { '<leader>R', group = '[R]est', icon = '󰏚' },
      },
    },
  },
}
