return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'

    lint.linters.rumdl.stream = 'stdout'

    lint.linters_by_ft = {
      python = { 'ruff' },
      go = { 'golangcilint' },

      sh = { 'shellcheck' },
      bash = { 'shellcheck' },

      markdown = { 'rumdl' },
    }

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        local path = vim.fn.expand '%:p'
        if path:find 'leetcode' or not vim.bo.modifiable or vim.bo.filetype == '' then
          return
        end
        if vim.bo.filetype == 'markdown' then
          return
        end
        lint.try_lint()
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
