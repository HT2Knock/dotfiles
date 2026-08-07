return {
  'akinsho/git-conflict.nvim',
  version = '*',
  event = 'BufRead',
  opts = {},
  keys = {
    {
      '<leader>gx',
      '<cmd>GitConflictListQf<cr>',
      desc = 'List git conflicts in quickfix',
    },
  },
}
