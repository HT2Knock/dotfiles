return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  opts = {
    notify_on_error = true,
    format_on_save = function(bufnr)
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] or vim.b[bufnr].dbui_db_key_name then
        return nil
      end
      return {
        timeout_ms = 2500,
        lsp_format = 'fallback',
      }
    end,
    formatters_by_ft = {
      python = { 'ruff_organize_imports', 'ruff_format' },
      javascript = { 'prettier' },
      typescript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescriptreact = { 'prettier' },
      json = { 'prettier' },
      jsonc = { 'prettier' },
      css = { 'prettier' },
      scss = { 'prettier' },
      html = { 'prettier' },
      markdown = { 'prettier', 'rumdl' },
      yaml = { 'prettier' },
      astro = { 'prettier' },
      sql = { 'sleek' },
      sh = { 'shfmt' },
    },
  },
  keys = {
    {
      '<leader>cf',
      function()
        if vim.b.dbui_db_key_name then
          vim.notify('DBUI buffer: visual-select the SQL, then <leader>cf', vim.log.levels.INFO)
          return
        end
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      desc = 'Format',
    },
    {
      '<leader>cf',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = 'v',
      desc = 'Format selection',
    },
  },
}
