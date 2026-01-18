return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-context',
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    opts = {
      select = {
        lookahead = true,
      },
    },
  },
  {
    'MeanderingProgrammer/treesitter-modules.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'go',
        'astro',
        'typescript',
        'javascript',
        'diff',
        'html',
        'css',
        'lua',
        'tsx',
        'json',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'python',
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      fold = { enable = true },
      incremental_selection = { enable = true },
    },
  },
}
