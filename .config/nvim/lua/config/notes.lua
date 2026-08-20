local M = {}

---@type string personal notes workspace (with trailing slash)
M.dir = vim.fn.fnamemodify(vim.fn.expand '~/Documents/T2Knock/JT-notes', ':p')

---@param path? string absolute or relative path; defaults to current buffer
---@return boolean
function M.is_note(path)
  path = path or vim.fn.expand '%:p'
  if not path or path == '' then
    return false
  end
  return vim.startswith(vim.fn.fnamemodify(path, ':p'), M.dir)
end

return M
