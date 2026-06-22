-- fff.nvim - the fastest Neovim file picker (Rust core, frecency-ranked)
-- https://github.com/dmtrKovalenko/fff.nvim
-- Owns the primary file-finding keys; snacks.picker file finder is kept on
-- <leader>fF for a direct speed comparison (see snack.lua).
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
  },
}
