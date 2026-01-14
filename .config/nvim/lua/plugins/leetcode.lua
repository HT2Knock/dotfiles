local leet_arg = 'leetcode.nvim'
return {
  'kawre/leetcode.nvim',
  lazy = leet_arg ~= vim.fn.argv(0, -1),
  cmd = 'Leet',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
  },
  opts = {
    arg = leet_arg,
    lang = 'golang',
    picker = {
      provider = 'snacks-picker',
    },
    storage = {
      home = vim.fn.expand '$HOME' .. '/workspace/github.com/T2Knock/leetcode',
    },
  },
}
