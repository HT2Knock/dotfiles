return {
  'lewis6991/gitsigns.nvim',
  event = 'BufRead',
  opts = {
    current_line_blame = true,
    signs = {
      delete = { text = '✖' },
      topdelete = { text = '▔' },
    },
  },
  keys = {
    -- Navigation
    {
      ']c',
      function()
        if vim.wo.diff then
          return ']c'
        end
        vim.schedule(function()
          require('gitsigns').nav_hunk 'next'
        end)
        return '<Ignore>'
      end,
      desc = 'Jump to next git [c]hange',
      expr = true,
    },
    {
      '[c',
      function()
        if vim.wo.diff then
          return '[c'
        end
        vim.schedule(function()
          require('gitsigns').nav_hunk 'prev'
        end)
        return '<Ignore>'
      end,
      desc = 'Jump to previous git [c]hange',
      expr = true,
    },

    -- Actions - Normal mode
    {
      '<leader>hp',
      '<cmd>Gitsigns preview_hunk<cr>',
      desc = 'git [p]review hunk',
    },
    {
      '<leader>hs',
      '<cmd>Gitsigns stage_hunk<cr>',
      desc = 'git [s]tage hunk',
    },
    {
      '<leader>hr',
      '<cmd>Gitsigns reset_hunk<cr>',
      desc = 'git [r]eset hunk',
    },
    {
      '<leader>hS',
      '<cmd>Gitsigns stage_buffer<cr>',
      desc = 'git [S]tage buffer',
    },
    {
      '<leader>hu',
      '<cmd>Gitsigns undo_stage_hunk<cr>',
      desc = 'git [u]ndo stage hunk',
    },
    {
      '<leader>hR',
      '<cmd>Gitsigns reset_buffer<cr>',
      desc = 'git [R]eset buffer',
    },
    {
      '<leader>hb',
      '<cmd>Gitsigns blame<cr>',
      desc = 'git [b]lame buffer',
    },
    {
      '<leader>hd',
      '<cmd>Gitsigns diffthis<cr>',
      desc = 'git [d]iff against index',
    },
    {
      '<leader>hD',
      function()
        require('gitsigns').diffthis '@'
      end,
      desc = 'git [D]iff against last commit',
    },
    {
      '<leader>hQ',
      function()
        require('gitsigns').setqflist 'all'
      end,
      desc = 'git [Q]uick fix all hunk',
    },
    {
      '<leader>hq',
      function()
        require('gitsigns').setqflist()
      end,
      desc = 'git [Q]uick fix all hunk',
    },

    -- Visual mode actions
    {
      '<leader>hs',
      function()
        require('gitsigns').stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end,
      mode = 'v',
      desc = 'git [s]tage hunk',
    },
    {
      '<leader>hr',
      function()
        require('gitsigns').reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end,
      mode = 'v',
      desc = 'git [r]eset hunk',
    },
  },
}
