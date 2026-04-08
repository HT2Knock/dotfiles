return {
  'nickjvandyke/opencode.nvim',
  version = '*',
  dependencies = {
    { 'folke/snacks.nvim', optional = true },
  },
  keys = {
    {
      '<leader>av',
      function()
        require('opencode').ask('@this: ', { submit = true })
      end,
      mode = { 'n', 'v' },
      desc = 'Ask opencode (Visual Range)',
    },
    {
      '<leader>aa',
      function()
        require('opencode').select()
      end,
      desc = 'Execute opencode action',
    },
    {
      '<leader>at',
      function()
        require('opencode').toggle()
      end,
      desc = 'Toggle opencode',
    },
    {
      '<leader>ae',
      function()
        require('opencode').prompt 'explain'
      end,
      mode = { 'n', 'v' },
      desc = 'Explain code',
    },
    {
      '<leader>ar',
      function()
        require('opencode').prompt 'review'
      end,
      mode = { 'n', 'v' },
      desc = 'Review code',
    },
    {
      '<leader>af',
      function()
        require('opencode').prompt 'fix'
      end,
      mode = { 'n', 'v' },
      desc = 'Fix errors',
    },
  },
}
