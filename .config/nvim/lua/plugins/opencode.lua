return {
  'nickjvandyke/opencode.nvim',
  version = '*', -- Latest stable release
  dependencies = {
    {
      'folke/snacks.nvim',
      optional = true,
    },
  },
  keys = {
    {
      '<leader>av',
      function()
        require('opencode').ask('@this: ', { submit = true })
      end,
      desc = 'Ask opencode',
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
         require('opencode').prompt('explain')
       end,
       desc = 'Explain code with opencode',
     },
     {
       '<leader>ar',
       function()
         require('opencode').prompt('review')
       end,
       desc = 'Review code with opencode',
     },
     {
       '<leader>af',
       function()
         require('opencode').prompt('fix')
       end,
       desc = 'Fix errors with opencode',
     },
  },
}
