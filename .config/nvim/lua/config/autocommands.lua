local function augroup(name)
  return vim.api.nvim_create_augroup('ht2knock_' .. name, { clear = true })
end

-- Check if we need to reload the file when it changed externally
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  desc = 'Check if file changed on disk',
  group = augroup 'checktime',
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd 'checktime'
    end
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight on yank',
  group = augroup 'highlight_yank',
  callback = function()
    vim.hl.on_yank { higroup = 'IncSearch', timeout = 200 }
  end,
})

vim.api.nvim_create_autocmd('VimResized', {
  desc = 'Resize splits on terminal resize',
  group = augroup 'resize_splits',
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd 'tabdo wincmd ='
    vim.cmd('tabnext ' .. current_tab)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Disable auto-commenting new lines',
  group = augroup 'no_auto_comment',
  callback = function()
    vim.schedule(function()
      vim.opt_local.formatoptions:remove { 'c', 'r', 'o' }
    end)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'FileType specific settings',
  group = augroup 'filetype_settings',
  pattern = { 'markdown', 'text', 'gitcommit' },
  callback = function(args)
    vim.opt_local.wrap = true
    vim.opt_local.spell = true

    if vim.bo[args.buf].filetype == 'markdown' then
      vim.opt_local.textwidth = 80
    end
  end,
})

-- Smart Cursorline (only in active window)
local cursorline_group = augroup 'active_cursorline'
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
  group = cursorline_group,
  callback = function()
    vim.wo.cursorline = true
  end,
})
vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
  group = cursorline_group,
  callback = function()
    vim.wo.cursorline = false
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Return to last edit position',
  group = augroup 'last_loc',
  callback = function(event)
    local exclude = { 'gitcommit' }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].ht2knock_last_loc then
      return
    end
    vim.b[buf].ht2knock_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
      vim.cmd 'normal! zz'
    end
  end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup 'auto_create_dir',
  callback = function(event)
    if event.match:match '^%w%w+:[\\/][\\/]' then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Close certain filetypes with <q>
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Close with q',
  group = augroup 'close_with_q',
  pattern = {
    'checkhealth',
    'help',
    'lspinfo',
    'notify',
    'qf',
    'startuptime',
    'grug-far',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        pcall(vim.cmd.close)
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = 'Quit buffer',
      })
    end)
  end,
})

-- Make man pages unlisted
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Make man pages unlisted',
  group = augroup 'man_unlisted',
  pattern = { 'man' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Fix JSON conceallevel',
  group = augroup 'json_conceal',
  pattern = { 'json', 'jsonc', 'json5' },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})
