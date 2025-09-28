require 'config.options'
require 'config.lazy'
require 'config.lsp'
require 'config.keymaps'
require 'config.autocommands'

-- Setting
vim.cmd [[colorscheme tokyonight]]
vim.filetype.add {
  extension = {
    http = 'http',
    env = 'conf',
  },
  pattern = {
    ['.*%.env%..+'] = 'conf',
  },
}

-- Global winbar bg
vim.api.nvim_set_hl(0, 'WinBar', { bg = '#1a1b26' })
vim.api.nvim_set_hl(0, 'WinBarNC', { bg = '#1a1b26' })
