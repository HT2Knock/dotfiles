-- Clear search highlights
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Insert blank line below current line
vim.keymap.set('n', '<leader>k', 'i<CR><Esc>', { desc = 'Insert line below' })

-- Buffer navigation
vim.keymap.set('n', 'H', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', 'L', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Delete buffer' })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '[e', function()
  vim.diagnostic.jump { severity = vim.diagnostic.severity.ERROR, count = -1 }
end, { desc = 'Jump to previous error' })
vim.keymap.set('n', ']e', function()
  vim.diagnostic.jump { severity = vim.diagnostic.severity.ERROR, count = 1 }
end, { desc = 'Jump to next error' })
vim.keymap.set('n', '<leader>cd', function()
  vim.diagnostic.open_float()
end, { desc = 'Show diagnostics for current line' })

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

-- Quickfix navigation
vim.keymap.set('n', '<M-j>', '<cmd>cnext<CR>', { desc = 'Quickfix: next item' })
vim.keymap.set('n', '<M-k>', '<cmd>cprevious<CR>', { desc = 'Quickfix: previous item' })

-- Location list navigation
vim.keymap.set('n', '<M-n>', '<cmd>lnext<CR>', { desc = 'Location list: next item' })
vim.keymap.set('n', '<M-p>', '<cmd>lprevious<CR>', { desc = 'Location list: previous item' })

-- Jump to first/last quickfix item
vim.keymap.set('n', '<M-h>', '<cmd>cfirst<CR>', { desc = 'Quickfix: first item' })
vim.keymap.set('n', '<M-l>', '<cmd>clast<CR>', { desc = 'Quickfix: last item' })

-- better up/down
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
