-- Prose linting with harper-ls.
--
-- Most Markdown opened here is agent output that gets read, not proofread. harper-ls
-- flags spelling and style on every line, so it stays off by default. Turn it on with
-- <leader>tn when you want a prose review. See lua/config/lsp.lua for the attach gate.
local M = {}

local enabled = false

---@return boolean
function M.enabled()
  return enabled
end

---@param state boolean
function M.set(state)
  enabled = state
  vim.lsp.enable('harper_ls', state)

  if state then
    -- Attach to prose buffers that are already open. Skip modified buffers so a reload
    -- cannot discard unsaved text.
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local filetype = vim.bo[buf].filetype
      if vim.api.nvim_buf_is_loaded(buf) and (filetype == 'markdown' or filetype == 'text') and not vim.bo[buf].modified then
        vim.lsp.start(vim.lsp.config['harper_ls'], { bufnr = buf })
      end
    end
  else
    for _, client in ipairs(vim.lsp.get_clients { name = 'harper_ls' }) do
      client:stop(true)
    end
  end
end

function M.toggle()
  M.set(not enabled)
end

return M
