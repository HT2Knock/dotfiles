return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },
    opts = {},
  },
  {
    'obsidian-nvim/obsidian.nvim',
    version = '*',
    lazy = true,
    event = {
      'BufReadPre ' .. vim.fn.expand '~' .. '/workspace/github.com/T2Knock/JT-notes/*.md',
      'BufNewFile ' .. vim.fn.expand '~' .. '/workspace/github.com/T2Knock/JT-notes/*.md',
    },
    opts = {
      workspaces = {
        {
          name = 'personal',
          path = '~/workspace/github.com/T2Knock/JT-notes',
        },
      },
      daily_notes = {
        folder = 'dailies',
        template = 'daily_note.md',
        default_tags = { 'daily-notes' },
        workdays_only = false,
      },
      picker = {
        name = 'snacks.pick',
      },
      templates = {
        folder = 'templates',
        date_format = '%Y-%m-%d',
        time_format = '%H:%M',
        substitutions = {
          yesterday = function()
            return os.date('%Y-%m-%d', os.time() - 86400)
          end,
          tomorrow = function()
            return os.date('%Y-%m-%d', os.time() + 86400)
          end,
          year = function()
            return os.date '%Y'
          end,
          month = function()
            return os.date '%m'
          end,
        },
        customizations = {
          weekly_review = {
            notes_subdir = 'review/weeklies',
            note_id_func = function(title)
              local name = title:lower():gsub('[^%w%s_-]', ''):gsub('%s+', '_')
              return name
            end,
          },
        },
      },
      attachments = {
        folder = 'resources/imgs',
      },
      legacy_commands = false,
      ui = {
        enabled = false,
      },
      checkbox = {
        enabled = true,
        create_new = false,
        order = { ' ', 'x', '~', '!', '>' },
      },
      note_id_func = function(title)
        local name = title:lower():gsub('[^%w%s_-]', ''):gsub('%s+', '_')
        return name
      end,
    },
    keys = {
      { '<leader>nd', '<cmd>Obsidian today<cr>', desc = 'Today Note' },
      { '<leader>ny', '<cmd>Obsidian yesterday<cr>', desc = 'Yesteday Note' },
      { '<leader>nt', '<cmd>Obsidian tomorrow<cr>', desc = 'Tomorrow Note' },
      { '<leader>nf', '<cmd>Obsidian search<cr>', desc = 'Find in notes' },
      { '<leader>np', '<cmd>Obsidian paste_img<cr>', desc = 'Paste image from clipboard' },
      { '<leader>nn', '<cmd>Obsidian new<cr>', desc = 'Create a new note' },
      { '<leader>nh', '<cmd>Obsidian new_from_template<cr>', desc = 'Insert template' },
    },
  },
}
