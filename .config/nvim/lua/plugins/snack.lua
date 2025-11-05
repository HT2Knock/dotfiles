local function setup_toggles()
  require('snacks').toggle
    .new({
      id = 'gitsigns_blame',
      name = ' Gitsigns Blame',
      get = function()
        return require('gitsigns.config').config.current_line_blame
      end,
      set = function(state)
        require('gitsigns').toggle_current_line_blame(state)
      end,
    })
    :map '<leader>tb'

  require('snacks').toggle.inlay_hints({ name = '󱄽 Inlay Hint' }):map '<leader>th'
  require('snacks').toggle.option('spell', { name = '󰓆 Spell Checking' }):map '<leader>ts'
  require('snacks').toggle.option('wrap', { name = '󰖶 Wrap Long Lines' }):map '<leader>tw'
  require('snacks').toggle.diagnostics({ name = ' Diagnostics' }):map '<leader>tD'
  require('snacks').toggle.treesitter({ name = ' Treesitter Highlighting' }):map '<leader>tt'
  require('snacks').toggle.zen():map '<leader>tz'
end

-- Keymap configurations organized by category
local keymaps = {
  -- Core navigation
  {
    '<leader><space>',
    function()
      require('snacks').picker.smart()
    end,
    desc = 'Smart Find Files',
  },
  {
    '<leader>,',
    function()
      require('snacks').picker.buffers { focus = 'list' }
    end,
    desc = 'Buffers',
  },
  -- File operations (f prefix)
  {
    '<leader>fc',
    function()
      require('snacks').picker.files { cwd = vim.fn.stdpath 'config' }
    end,
    desc = 'Find Config File',
  },
  {
    '<leader>fC',
    function()
      require('snacks').picker.colorschemes()
    end,
    desc = 'Colorschemes',
  },
  {
    '<leader>ff',
    function()
      require('snacks').picker.files()
    end,
    desc = 'Find Files',
  },
  {
    '<leader>fg',
    function()
      require('snacks').picker.git_files()
    end,
    desc = 'Find Git Files',
  },
  {
    '<leader>fp',
    function()
      require('snacks').picker.files { cwd = vim.fs.joinpath(vim.fn.stdpath 'data', 'lazy') }
    end,
    desc = 'Search for packages',
  },
  {
    '<leader>fr',
    function()
      require('snacks').picker.recent()
    end,
    desc = 'Recent',
  },

  -- Git operations (g prefix)
  {
    '<leader>gg',
    function()
      require('snacks').lazygit()
    end,
    desc = 'Lazygit',
  },
  {
    '<leader>gb',
    function()
      require('snacks').picker.git_branches()
    end,
    desc = 'Git Branches',
  },
  {
    '<leader>gl',
    function()
      require('snacks').picker.git_log()
    end,
    desc = 'Git Log',
  },
  {
    '<leader>gL',
    function()
      require('snacks').picker.git_log_line()
    end,
    desc = 'Git Log Line',
  },
  {
    '<leader>gs',
    function()
      require('snacks').picker.git_status()
    end,
    desc = 'Git Status',
  },
  {
    '<leader>gS',
    function()
      require('snacks').picker.git_stash()
    end,
    desc = 'Git Stash',
  },
  {
    '<leader>gd',
    function()
      require('snacks').picker.git_diff()
    end,
    desc = 'Git Diff (Hunks)',
  },
  {
    '<leader>gf',
    function()
      require('snacks').picker.git_log_file()
    end,
    desc = 'Git Log File',
  },

  -- Search operations (s prefix)
  {
    '<leader>s"',
    function()
      require('snacks').picker.registers()
    end,
    desc = 'Registers',
  },
  {
    '<leader>s/',
    function()
      require('snacks').picker.search_history()
    end,
    desc = 'Search History',
  },
  {
    '<leader>sa',
    function()
      require('snacks').picker.autocmds()
    end,
    desc = 'Autocmds',
  },
  {
    '<leader>sb',
    function()
      require('snacks').picker.lines()
    end,
    desc = 'Buffer Lines',
  },
  {
    '<leader>sB',
    function()
      require('snacks').picker.grep_buffers()
    end,
    desc = 'Grep Open Buffers',
  },
  {
    '<leader>sc',
    function()
      require('snacks').picker.command_history()
    end,
    desc = 'Command History',
  },
  {
    '<leader>sC',
    function()
      require('snacks').picker.commands()
    end,
    desc = 'Commands',
  },
  {
    '<leader>sd',
    function()
      require('snacks').picker.diagnostics()
    end,
    desc = 'Diagnostics',
  },
  {
    '<leader>sD',
    function()
      require('snacks').picker.diagnostics_buffer()
    end,
    desc = 'Buffer Diagnostics',
  },
  {
    '<leader>sg',
    function()
      require('snacks').picker.grep()
    end,
    desc = 'Grep',
  },
  {
    '<leader>sh',
    function()
      require('snacks').picker.help()
    end,
    desc = 'Help Pages',
  },
  {
    '<leader>sH',
    function()
      require('snacks').picker.highlights()
    end,
    desc = 'Highlights',
  },
  {
    '<leader>si',
    function()
      require('snacks').picker.icons()
    end,
    desc = 'Icons',
  },
  {
    '<leader>sj',
    function()
      require('snacks').picker.jumps()
    end,
    desc = 'Jumps',
  },
  {
    '<leader>sk',
    function()
      require('snacks').picker.keymaps()
    end,
    desc = 'Keymaps',
  },
  {
    '<leader>sl',
    function()
      require('snacks').picker.loclist()
    end,
    desc = 'Location List',
  },
  {
    '<leader>sm',
    function()
      require('snacks').picker.marks()
    end,
    desc = 'Marks',
  },
  {
    '<leader>sM',
    function()
      require('snacks').picker.man()
    end,
    desc = 'Man Pages',
  },
  {
    '<leader>sq',
    function()
      require('snacks').picker.qflist()
    end,
    desc = 'Quickfix List',
  },
  {
    '<leader>sR',
    function()
      require('snacks').picker.resume()
    end,
    desc = 'Resume',
  },
  {
    '<leader>ss',
    function()
      require('snacks').picker.lsp_symbols()
    end,
    desc = 'LSP Symbols',
  },
  {
    '<leader>sS',
    function()
      require('snacks').picker.lsp_workspace_symbols()
    end,
    desc = 'LSP Workspace Symbols',
  },
  {
    '<leader>su',
    function()
      require('snacks').picker.undo()
    end,
    desc = 'Undo History',
  },
  {
    '<leader>sw',
    function()
      require('snacks').picker.grep_word()
    end,
    desc = 'Visual selection or word',
    mode = { 'n', 'x' },
  },

  -- LSP operations
  {
    'gd',
    function()
      require('snacks').picker.lsp_definitions()
    end,
    desc = 'Goto Definition',
  },
  {
    'gD',
    function()
      require('snacks').picker.lsp_declarations()
    end,
    desc = 'Goto Declaration',
  },
  {
    'grr',
    function()
      require('snacks').picker.lsp_references()
    end,
    nowait = true,
    desc = 'References',
  },
  {
    'gri',
    function()
      require('snacks').picker.lsp_implementations()
    end,
    desc = 'Goto Implementation',
  },
  {
    'grt',
    function()
      require('snacks').picker.lsp_type_definitions()
    end,
    desc = 'Goto T[y]pe Definition',
  },
}

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,

  opts = {
    animate = { enabled = true },
    bigfile = { enabled = true },
    scroll = { enabled = true },
    lazygit = { enabled = true },
    statuscolumn = { enabled = true },
    explorer = { enabled = true },
    toggle = { enabled = true },
    input = { enabled = true },
    words = { enabled = true },
    quickfile = { enabled = true },
    rename = { enabled = true },
    health = { enabled = true },
    zen = {
      toggles = { dim = false },
      win = {
        backdrop = {
          transparent = false,
        },
      },
    },
    image = {
      enabled = true,
      resolve = function(path, src)
        if require('obsidian.api').path_is_note(path) then
          return require('obsidian.api').resolve_image_path(src)
        end
      end,
    },
    picker = {},
  },

  keys = keymaps,

  config = function(_, opts)
    require('snacks').setup(opts)
    setup_toggles()
  end,
}
