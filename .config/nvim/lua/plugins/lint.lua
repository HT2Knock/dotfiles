return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'

    lint.linters_by_ft = {
      javascript = { 'eslint' },
      javascriptreact = { 'eslint' },
      typescript = { 'eslint' },
      typescriptreact = { 'eslint' },
      svelte = { 'eslint' },
      vue = { 'eslint' },

      python = { 'ruff' },
      go = { 'golangcilint' },

      sh = { 'shellcheck' },
      bash = { 'shellcheck' },

      markdown = { 'markdownlint-cli2' },
    }

    -- Create autocommand for linting
    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        -- Only lint if buffer is modifiable and has a filetype
        if vim.bo.modifiable and vim.bo.filetype ~= '' then
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
