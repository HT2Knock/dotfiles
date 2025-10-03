return {
  {
    'A7Lavinraj/fyler.nvim',
    dependencies = { 'nvim-mini/mini.icons' },
    branch = 'stable',
    opts = {
      confirm_simple = true,
      default_explorer = true,
    },
    keys = {
      { '-', '<cmd>Fyler<CR>', desc = 'Open current working directory' },
    },
  },
}
