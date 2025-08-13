return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'jbyuki/one-small-step-for-vimkind',
      'leoluz/nvim-dap-go',
      'mfussenegger/nvim-dap-python',
    },
    config = function()
      -- Highlights
      vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#f7768e' })
      vim.api.nvim_set_hl(0, 'DapBreakpointHollow', { fg = '#7aa2f7' })
      vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#9ece6a' })
      vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#bb9af7' })

      -- Signs
      local breakpoint_icons = {
        Breakpoint = '●',
        BreakpointCondition = '●',
        BreakpointRejected = '◌',
        LogPoint = '◆',
        Stopped = '▶',
      }

      for type, icon in pairs(breakpoint_icons) do
        local hl = (type == 'Stopped') and 'DapStopped' or 'DapBreak'
        local opts = { text = icon, texthl = hl, numhl = hl }

        if type == 'Stopped' then
          opts.linehl = 'DapStoppedLine'
        end

        vim.fn.sign_define('Dap' .. type, opts)
      end

      require('dap-python').setup 'uv'
      require 'adapters.node'
    end,
  },
  {
    'miroshQa/debugmaster.nvim',
    config = function()
      local dm = require 'debugmaster'
      vim.keymap.set({ 'n', 'v' }, '<leader>m', dm.mode.toggle, { nowait = true })
      vim.api.nvim_set_hl(0, 'dCursor', { bg = '#7aa2f7' })
      dm.plugins.osv_integration.enabled = true
    end,
  },
  {
    'rareitems/printer.nvim',
    config = function()
      require('printer').setup {
        keymap = 'gp',
      }
    end,
  },
}
