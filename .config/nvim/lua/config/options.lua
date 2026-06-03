local opt = vim.opt

-- Leader & globals
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- UI appearance
opt.showmode = false
opt.number = true
opt.relativenumber = true
opt.signcolumn = 'yes'
opt.cursorline = true
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
opt.fillchars = { foldopen = '', foldclose = '', fold = ' ', foldsep = ' ', diff = '╱', eob = ' ' }
opt.laststatus = 3
opt.ruler = false
opt.pumblend = 10
opt.pumheight = 10
opt.winborder = 'rounded'
opt.inccommand = 'split'

-- Editor behavior
opt.mouse = 'a'
opt.confirm = true
opt.breakindent = true
opt.linebreak = true
opt.wrap = false
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.smoothscroll = true
opt.virtualedit = 'block'
opt.jumpoptions = 'view'
opt.updatetime = 250
opt.timeoutlen = 300

-- Indentation & tabs
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.shiftround = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.grepprg = 'rg --vimgrep'
opt.grepformat = '%f:%l:%c:%m'

-- Folding
opt.foldmethod = 'expr'
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
opt.foldtext = ''
opt.foldlevel = 99
opt.conceallevel = 2

-- Clipboard & system
opt.clipboard = vim.env.SSH_CONNECTION and '' or 'unnamedplus'

-- Completion & cmdline
opt.completeopt = 'menu,menuone,noselect'
opt.wildmode = 'longest:full,full'
opt.shortmess:append { W = true, I = true, c = true, C = true }

-- Spelling
opt.spelllang = 'en'
opt.spellfile = vim.fn.stdpath 'config' .. '/spell/en.utf-8.add'
opt.spelloptions = 'camel'

-- Undo & history
opt.undofile = true
opt.undolevels = 10000

-- Session
opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }

-- Window & splits
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = 'screen'
opt.winminwidth = 5

-- Formatting (lazy-loaded check)
local has_conform, _ = pcall(require, 'conform')
if has_conform then
  opt.formatexpr = "v:lua.require'conform'.formatexpr()"
end
