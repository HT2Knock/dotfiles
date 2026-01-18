return {
  { 'nvim-mini/mini.icons', version = '*', opts = {} },
  {
    'echasnovski/mini.surround',
    version = '*',
    opts = {
      mappings = {
        add = 'sa', -- Add surrounding (normal mode)
        delete = 'sd', -- Delete surrounding
        find = 'sf', -- Find left surrounding
        find_right = 'sF', -- Find right surrounding
        highlight = 'sh', -- Highlight surrounding
        replace = 'sr', -- Replace surrounding
        update_n_lines = 'sn', -- Update `n_lines`
      },
    },
  },
}
