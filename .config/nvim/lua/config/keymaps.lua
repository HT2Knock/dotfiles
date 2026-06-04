-- Clear search highlights
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Insert blank line below current line
vim.keymap.set('n', '<leader>k', 'i<CR><Esc>', { desc = 'Insert line below' })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '[e', function()
  vim.diagnostic.jump { severity = vim.diagnostic.severity.ERROR, count = -1 }
end, { desc = 'Jump to previous error' })
vim.keymap.set('n', ']e', function()
  vim.diagnostic.jump { severity = vim.diagnostic.severity.ERROR, count = 1 }
end, { desc = 'Jump to next error' })

-- Window navigation
-- See `:help wincmd` for all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper window' })

-- Window movement
vim.keymap.set('n', '<C-S-h>', '<C-w>H', { desc = 'Move window left' })
vim.keymap.set('n', '<C-S-l>', '<C-w>L', { desc = 'Move window right' })
vim.keymap.set('n', '<C-S-j>', '<C-w>J', { desc = 'Move window down' })
vim.keymap.set('n', '<C-S-k>', '<C-w>K', { desc = 'Move window up' })

-- Resize window using <ctrl> arrow keys
vim.keymap.set('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
vim.keymap.set('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

-- Location list navigation
vim.keymap.set('n', '<M-n>', '<cmd>lnext<CR>', { desc = 'Location list: next item' })
vim.keymap.set('n', '<M-p>', '<cmd>lprevious<CR>', { desc = 'Location list: previous item' })

-- Jump to first/last quickfix item
vim.keymap.set('n', '<M-h>', '<cmd>cfirst<CR>', { desc = 'Quickfix: first item' })
vim.keymap.set('n', '<M-l>', '<cmd>clast<CR>', { desc = 'Quickfix: last item' })

-- Quickfix navigation (vim-style)
vim.keymap.set('n', '[q', '<cmd>cprevious<cr>', { desc = 'Previous Quickfix' })
vim.keymap.set('n', ']q', '<cmd>cnext<cr>', { desc = 'Next Quickfix' })

-- better up/down
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Saner n/N behavior (respects search direction and opens folds)
vim.keymap.set({ 'n', 'x', 'o' }, 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next Search Result' })
vim.keymap.set({ 'n', 'x', 'o' }, 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Previous Search Result' })

-- Add undo break-points
vim.keymap.set('i', ',', ',<c-g>u')
vim.keymap.set('i', '.', '.<c-g>u')
vim.keymap.set('i', ';', ';<c-g>u')

-- Save file in all modes
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save File' })

-- context upward
vim.keymap.set('n', '[;', function()
  require('treesitter-context').go_to_context(vim.v.count1)
end, { desc = 'Go upward in context', silent = true })

-- text object
vim.keymap.set({ 'x', 'o' }, 'af', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'if', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
end)

vim.keymap.set({ 'x', 'o' }, 'ab', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@block.outer', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'ib', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@block.inner', 'textobjects')
end)

vim.keymap.set({ 'x', 'o' }, 'al', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@loop.outer', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'il', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@loop.inner', 'textobjects')
end)

vim.keymap.set({ 'x', 'o' }, 'aa', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@parameter.outer', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'ia', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@parameter.inner', 'textobjects')
end)

vim.keymap.set({ 'n', 'o', 'x' }, ']f', function()
  require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
end, { desc = 'Next function' })
vim.keymap.set({ 'n', 'o', 'x' }, ']F', function()
  require('nvim-treesitter-textobjects.move').goto_previous('@function.outer', 'textobjects')
end, { desc = 'Previous function' })

-- Move lines with Alt+j/k
vim.keymap.set('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move Down' })
vim.keymap.set('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move Up' })
vim.keymap.set('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Down' })
vim.keymap.set('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Up' })
vim.keymap.set('v', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move Down' })
vim.keymap.set('v', '<A-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = 'Move Up' })

-- Buffer navigation
vim.keymap.set('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Previous Buffer' })
vim.keymap.set('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
vim.keymap.set('n', '[b', '<cmd>bprevious<cr>', { desc = 'Previous Buffer' })
vim.keymap.set('n', ']b', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<leader>bb', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })
vim.keymap.set('n', '<leader>`', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })

-- Buffer deletion with Snacks
vim.keymap.set('n', '<leader>bd', function()
  local ok, snacks = pcall(require, 'snacks')
  if ok then
    snacks.bufdelete()
  end
end, { desc = 'Delete Buffer' })
vim.keymap.set('n', '<leader>bo', function()
  local ok, snacks = pcall(require, 'snacks')
  if ok then
    snacks.bufdelete.other()
  end
end, { desc = 'Delete Other Buffers' })
vim.keymap.set('n', '<leader>bD', '<cmd>:bd<cr>', { desc = 'Delete Buffer and Window' })

-- Clear search, diff update and redraw
vim.keymap.set('n', '<leader>ur', '<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>', { desc = 'Redraw / Clear hlsearch / Diff Update' })

-- Keywordprg
vim.keymap.set('n', '<leader>K', '<cmd>norm! K<cr>', { desc = 'Keywordprg' })

-- Better indenting (keep visual selection)
vim.keymap.set('x', '<', '<gv')
vim.keymap.set('x', '>', '>gv')

-- Add comments above/below (uses built-in gc operator, Neovim 0.10+)
vim.keymap.set('n', 'gco', 'o<esc>gcc', { desc = 'Add Comment Below' })
vim.keymap.set('n', 'gcO', 'O<esc>gcc', { desc = 'Add Comment Above' })

-- Quickfix/location list toggle
vim.keymap.set('n', '<leader>xq', function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = 'Quickfix List' })

vim.keymap.set('n', '<leader>xl', function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = 'Location List' })

-- LSP codelens
vim.keymap.set('n', '<leader>cr', vim.lsp.codelens.run, { desc = '[C]odeLens [R]un' })
