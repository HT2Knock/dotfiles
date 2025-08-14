require 'config.options'
require 'config.lazy'
require 'config.lsp'
require 'config.keymaps'
require 'config.autocommands'

-- Setting
vim.cmd [[colorscheme tokyonight]]
vim.filetype.add { extension = { ['http'] = 'http' } }
