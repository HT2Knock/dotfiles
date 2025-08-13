return {
  {
    'stevearc/oil.nvim',
    lazy = false,
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    opts = {
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
          return name == '..' or name == '.git'
        end,
      },
    },
    keys = {
      { '-', '<cmd>Oil<CR>', desc = 'Open current working directory' },
    },
  },
  {
    'JezerM/oil-lsp-diagnostics.nvim',
    dependencies = { 'stevearc/oil.nvim' },
    opts = {},
  },
  {
    'benomahony/oil-git.nvim',
    dependencies = { 'stevearc/oil.nvim' },
  },
}
