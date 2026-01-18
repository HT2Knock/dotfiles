vim.g.mapleader = ' '
vim.g.maplocalleader = ','
vim.g.have_nerd_font = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.winborder = 'rounded'
vim.o.clipboard = 'unnamedplus'
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldtext = ''
vim.opt.foldlevel = 99
vim.opt.conceallevel = 2
vim.opt.spelllang = 'en'
vim.opt.spellfile = vim.fn.stdpath 'config' .. '/spell/en.utf-8.add'
vim.opt.spelloptions = 'camel'

local has_conform, _ = pcall(require, 'conform')
if has_conform then
  vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"
end
