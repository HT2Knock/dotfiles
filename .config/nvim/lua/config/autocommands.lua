local function augroup(name)
  return vim.api.nvim_create_augroup('ht2knock_' .. name, { clear = true })
end

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
  command = 'wincmd =',
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
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      vim.api.nvim_win_set_cursor(0, mark)
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
