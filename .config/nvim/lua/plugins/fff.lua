-- fff.nvim - the fastest Neovim file picker (Rust core, frecency-ranked)
-- https://github.com/dmtrKovalenko/fff.nvim
-- Owns the primary file-finding and grep keys (replaces snacks.picker for those).

-- Live grep prefilled with the word under the cursor (normal) or the visual
-- selection. Uses register z and restores it so nothing is clobbered.
local function grep_keyword()
  local mode = vim.fn.mode()
  local query
  if mode == 'v' or mode == 'V' or mode == '\22' then
    local save, save_type = vim.fn.getreg 'z', vim.fn.getregtype 'z'
    vim.cmd 'noautocmd normal! "zy'
    query = vim.fn.getreg 'z'
    vim.fn.setreg('z', save, save_type)
  else
    query = vim.fn.expand '<cword>'
  end
  require('fff').live_grep { query = query }
end

return {
  'dmtrKovalenko/fff.nvim',
  build = function()
    -- Downloads a prebuilt binary, falls back to `cargo build` if needed.
    require('fff.download').download_or_build_binary()
  end,
  lazy = false,
  ---@module 'fff'
  opts = {},
  keys = {
    {
      '<leader>ff',
      function()
        require('fff').find_files()
      end,
      desc = 'Find Files (fff)',
    },
    {
      '<leader><space>',
      function()
        require('fff').find_files()
      end,
      desc = 'Find Files (fff)',
    },
    {
      '<leader>sg',
      function()
        require('fff').live_grep()
      end,
      desc = 'Live Grep (fff)',
    },
    {
      '<leader>sw',
      grep_keyword,
      desc = 'Grep Word/Selection (fff)',
      mode = { 'n', 'x' },
    },
  },
}
