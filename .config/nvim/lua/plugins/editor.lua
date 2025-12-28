return {
  {
    'esmuellert/vscode-diff.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    cmd = 'CodeDiff',
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
  {
    'saxon1964/neovim-tips',
    version = '*',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'MeanderingProgrammer/render-markdown.nvim',
    },
    opts = {},
  },
  {
    'MagicDuck/grug-far.nvim',
    opts = {},
  },
  { 'NMAC427/guess-indent.nvim', event = 'BufReadPost', opts = {} },
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
