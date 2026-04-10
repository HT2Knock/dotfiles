require 'config.options'
require 'config.lazy'
require 'config.lsp'
require 'config.keymaps'
require 'config.autocommands'
require('vim._core.ui2').enable()

-- Setting
vim.cmd [[colorscheme tokyonight]]
vim.filetype.add {
  extension = {
    http = 'http',
    env = 'conf',
  },
  pattern = {
    ['.*http%-client%.env%.json'] = 'json',
    ['.*%.env%..+'] = 'conf',
  },
}
