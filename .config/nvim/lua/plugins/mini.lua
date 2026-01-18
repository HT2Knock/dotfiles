return {
  { 'nvim-mini/mini.icons', version = '*', opts = {} },
  {
    'echasnovski/mini.surround',
    version = '*',
    opts = {
      mappings = {
        add = 'sa', -- Add surrounding in Normal and Visua modes
        deete = 'sd', -- Delete surrounding
        find = 'sf', -- Find surrounding (to the right)
        find_left = 'sF', -- Find surrounding (to the left)
        highlight = 'sh', -- Highlight surrounding
        replace = 'sr', -- Replace surrounding

        suffix_last = 'l', -- Suffix to search with "prev" method
        suffix_next = 'n', -- Suffix to search with "next" method
      },
    },
  },
}
