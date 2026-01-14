return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'

    lint.linters_by_ft = {
      python = { 'ruff' },
      go = { 'golangcilint' },

      sh = { 'shellcheck' },
      bash = { 'shellcheck' },

      markdown = { 'rumdl' },
    }

    -- Create autocommand for linting
    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        local path = vim.fn.expand '%:p'
        if not path:find 'leetcode' and vim.bo.modifiable and vim.bo.filetype ~= '' then
          lint.try_lint()
        end
      end,
    })
  end,
  keys = {
    {
      '<leader>cl',
      function()
        require('lint').try_lint()
      end,
      desc = 'Lint',
    },
  },
}
