local function setup_toggles()
  Snacks.toggle
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

  Snacks.toggle
    .new({
      id = 'copilot',
      name = ' Copilot',
      get = function()
        local ok, client = pcall(require, 'copilot.client')
        if ok and client.is_disabled then
          return not client.is_disabled()
        end
        return false
      end,
      set = function(state)
        vim.cmd('Copilot ' .. (state and 'enable' or 'disable'))
      end,
    })
    :map '<leader>tc'

  Snacks.toggle.inlay_hints({ name = '󱄽 Inlay Hint' }):map '<leader>th'
  Snacks.toggle.option('spell', { name = '󰓆 Spell Checking' }):map '<leader>ts'
  Snacks.toggle.option('wrap', { name = '󰖶 Wrap Long Lines' }):map '<leader>tw'
  Snacks.toggle.diagnostics({ name = ' Diagnostics' }):map '<leader>tD'
  Snacks.toggle.treesitter({ name = ' Treesitter Highlighting' }):map '<leader>tt'
end

-- Keymap configurations organized by category
local keymaps = {
  -- Core navigation
  {
    '<leader><space>',
    function()
      Snacks.picker.smart()
    end,
    desc = 'Smart Find Files',
  },
  {
    '<leader>,',
    function()
      Snacks.picker.buffers { focus = 'list' }
    end,
    desc = 'Buffers',
  },
  {
    '<leader>:',
    function()
      Snacks.picker.command_history()
    end,
    desc = 'Command History',
  },
  {
    '<leader>e',
    function()
      Snacks.explorer { hidden = true }
    end,
    desc = 'File Explorer',
  },
  -- File operations (f prefix)
  {
    '<leader>fc',
    function()
      Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
    end,
    desc = 'Find Config File',
  },
  {
    '<leader>fC',
    function()
      Snacks.picker.colorschemes()
    end,
    desc = 'Colorschemes',
  },
  {
    '<leader>ff',
    function()
      Snacks.picker.files { hidden = true }
    end,
    desc = 'Find Files',
  },
  {
    '<leader>fg',
    function()
      Snacks.picker.git_files()
    end,
    desc = 'Find Git Files',
  },
  {
    '<leader>fp',
    function()
      Snacks.picker.files { cwd = vim.fs.joinpath(vim.fn.stdpath 'data', 'lazy') }
    end,
    desc = 'Search for packages',
  },
  {
    '<leader>fr',
    function()
      Snacks.picker.recent()
    end,
    desc = 'Recent',
  },

  -- Git operations (g prefix)
  {
    '<leader>gg',
    function()
      Snacks.lazygit()
    end,
    desc = 'Lazygit',
  },
  {
    '<leader>gb',
    function()
      Snacks.picker.git_branches()
    end,
    desc = 'Git Branches',
  },
  {
    '<leader>gl',
    function()
      Snacks.lazygit.log()
    end,
    desc = 'Git Log',
  },
  {
    '<leader>gL',
    function()
      Snacks.picker.git_log_line()
    end,
    desc = 'Git Log Line',
  },
  {
    '<leader>gs',
    function()
      Snacks.picker.git_status()
    end,
    desc = 'Git Status',
  },
  {
    '<leader>gS',
    function()
      Snacks.picker.git_stash()
    end,
    desc = 'Git Stash',
  },
  {
    '<leader>gd',
    function()
      Snacks.picker.git_diff()
    end,
    desc = 'Git Diff (Hunks)',
  },
  {
    '<leader>gf',
    function()
      Snacks.lazygit.log_file()
    end,
    desc = 'Git Log File',
  },

  -- Search operations (s prefix)
  {
    '<leader>s"',
    function()
      Snacks.picker.registers()
    end,
    desc = 'Registers',
  },
  {
    '<leader>s/',
    function()
      Snacks.picker.search_history()
    end,
    desc = 'Search History',
  },
  {
    '<leader>sa',
    function()
      Snacks.picker.autocmds()
    end,
    desc = 'Autocmds',
  },
  {
    '<leader>sb',
    function()
      Snacks.picker.lines()
    end,
    desc = 'Buffer Lines',
  },
  {
    '<leader>sB',
    function()
      Snacks.picker.grep_buffers()
    end,
    desc = 'Grep Open Buffers',
  },
  {
    '<leader>sc',
    function()
      Snacks.picker.command_history()
    end,
    desc = 'Command History',
  },
  {
    '<leader>sC',
    function()
      Snacks.picker.commands()
    end,
    desc = 'Commands',
  },
  {
    '<leader>sd',
    function()
      Snacks.picker.diagnostics()
    end,
    desc = 'Diagnostics',
  },
  {
    '<leader>sD',
    function()
      Snacks.picker.diagnostics_buffer()
    end,
    desc = 'Buffer Diagnostics',
  },
  {
    '<leader>sg',
    function()
      Snacks.picker.grep { hidden = true }
    end,
    desc = 'Grep',
  },
  {
    '<leader>sh',
    function()
      Snacks.picker.help()
    end,
    desc = 'Help Pages',
  },
  {
    '<leader>sH',
    function()
      Snacks.picker.highlights()
    end,
    desc = 'Highlights',
  },
  {
    '<leader>si',
    function()
      Snacks.picker.icons()
    end,
    desc = 'Icons',
  },
  {
    '<leader>sj',
    function()
      Snacks.picker.jumps()
    end,
    desc = 'Jumps',
  },
  {
    '<leader>sk',
    function()
      Snacks.picker.keymaps()
    end,
    desc = 'Keymaps',
  },
  {
    '<leader>sl',
    function()
      Snacks.picker.loclist()
    end,
    desc = 'Location List',
  },
  {
    '<leader>sm',
    function()
      Snacks.picker.marks()
    end,
    desc = 'Marks',
  },
  {
    '<leader>sM',
    function()
      Snacks.picker.man()
    end,
    desc = 'Man Pages',
  },
  {
    '<leader>sq',
    function()
      Snacks.picker.qflist()
    end,
    desc = 'Quickfix List',
  },
  {
    '<leader>sR',
    function()
      Snacks.picker.resume()
    end,
    desc = 'Resume',
  },
  {
    '<leader>ss',
    function()
      Snacks.picker.lsp_symbols()
    end,
    desc = 'LSP Symbols',
  },
  {
    '<leader>sS',
    function()
      Snacks.picker.lsp_workspace_symbols()
    end,
    desc = 'LSP Workspace Symbols',
  },
  {
    '<leader>su',
    function()
      Snacks.picker.undo()
    end,
    desc = 'Undo History',
  },
  {
    '<leader>sw',
    function()
      Snacks.picker.grep_word()
    end,
    desc = 'Visual selection or word',
    mode = { 'n', 'x' },
  },
  {
    '<leader>st',
    function()
      Snacks.picker.todo_comments { hidden = true }
    end,
    desc = 'Todo',
  },
  {
    '<leader>sT',
    function()
      Snacks.picker.todo_comments { keywords = { 'TODO', 'FIX', 'FIXME' }, hidden = true }
    end,
    desc = 'Todo/Fix/Fixme',
  },

  -- LSP operations
  {
    'gd',
    function()
      Snacks.picker.lsp_definitions()
    end,
    desc = 'Goto Definition',
  },
  {
    'gD',
    function()
      Snacks.picker.lsp_declarations()
    end,
    desc = 'Goto Declaration',
  },
  {
    'grr',
    function()
      Snacks.picker.lsp_references()
    end,
    nowait = true,
    desc = 'References',
  },
  {
    'gri',
    function()
      Snacks.picker.lsp_implementations()
    end,
    desc = 'Goto Implementation',
  },
  {
    'grt',
    function()
      Snacks.picker.lsp_type_definitions()
    end,
    desc = 'Goto T[y]pe Definition',
  },
  {
    'gai',
    function()
      Snacks.picker.lsp_incoming_calls()
    end,
    desc = 'C[a]lls Incoming',
  },
  {
    'gao',
    function()
      Snacks.picker.lsp_outgoing_calls()
    end,
    desc = 'C[a]lls Outgoing',
  },
  {
    '<C-/>',
    function()
      Snacks.terminal.toggle()
    end,
    desc = 'Toggle Terminal',
  },
}

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    lazygit = { enabled = true },
    input = { enabled = true },
    statuscolumn = { enabled = true },
    explorer = { enabled = true },
    toggle = { enabled = true },
    terminal = { enabled = true },
    words = { enabled = true },
    quickfile = { enabled = true },
    rename = { enabled = true },
    health = { enabled = true },
    image = {
      enabled = true,
      resolve = function(path, src)
        if require('obsidian.api').path_is_note(path) then
          return require('obsidian.api').resolve_image_path(src)
        end
      end,
    },
    notifier = {
      enabled = true,
      style = 'minimal',
    },
    picker = {
      layout = 'ivy',
    },
  },

  keys = keymaps,

  config = function(_, opts)
    Snacks.setup(opts)
    setup_toggles()
  end,
}
