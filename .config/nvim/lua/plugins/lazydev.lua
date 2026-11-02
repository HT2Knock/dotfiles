return {
  'folke/lazydev.nvim',
  ft = 'lua',
  opts = {
    library = {
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      { path = vim.fn.stdpath 'data' .. '/lazy/snacks.nvim', words = { 'Snacks' } },
      { path = vim.fn.expand '~/.config/rex/types', words = { 'rex%.' } },
    },
  },
}
