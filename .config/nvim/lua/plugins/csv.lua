return {
  {
    'hat0uma/csvview.nvim',
    ft = { 'csv', 'tsv' },
    cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
    ---@module 'csvview'
    ---@type CsvView.Options
    opts = {
      parser = { comments = { '#', '//' } },
      keymaps = {
        -- Text objects for fields
        textobject_field_inner = { 'if', mode = { 'o', 'x' } },
        textobject_field_outer = { 'af', mode = { 'o', 'x' } },
        -- Spreadsheet-like motion between fields
        jump_next_field_end = { '<Tab>', mode = { 'n', 'v' } },
        jump_prev_field_end = { '<S-Tab>', mode = { 'n', 'v' } },
        jump_next_row = { '<Enter>', mode = { 'n', 'v' } },
        jump_prev_row = { '<S-Enter>', mode = { 'n', 'v' } },
      },
    },
    config = function(_, opts)
      local csvview = require 'csvview'
      csvview.setup(opts)

      -- Show the table view as soon as a CSV or TSV buffer opens.
      local group = vim.api.nvim_create_augroup('csvview_auto_enable', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = { 'csv', 'tsv' },
        callback = function(args)
          csvview.enable(args.buf)
        end,
      })
      if vim.tbl_contains({ 'csv', 'tsv' }, vim.bo.filetype) then
        csvview.enable(0)
      end
    end,
  },
}
