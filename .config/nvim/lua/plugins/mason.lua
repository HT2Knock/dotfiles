return {
  {
    'mason-org/mason.nvim',
    opts = {},
  },
  {
    'mason-org/mason-lspconfig.nvim',
    opts = {
      automatic_enable = {
        exclude = { 'tsgo', 'ts_ls' },
      },
    },
    dependencies = {
      'mason-org/mason.nvim',
      'neovim/nvim-lspconfig',
    },
  },
  {
    'neovim/nvim-lspconfig',
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = {
      'mason-org/mason.nvim',
    },
    opts = {
      ensure_installed = {
        -- LSP
        'lua-language-server',
        'astro-language-server',
        'tailwindcss-language-server',
        'gopls',
        'harper-ls',
        'ruff',
        'ty',
        'taplo',
        'bash-language-server',
        'yaml-language-server',
        'json-lsp',
        'eslint-lsp',
        'postgres-language-server',
        'css-lsp',
        'tsc',

        -- DAP
        'delve',
        'debugpy',
        'js-debug-adapter',

        -- Linter
        'shellcheck',
        'golangci-lint',
        'rumdl',

        -- Formatter
        'prettier',
        'gofumpt',
        'goimports',
        'shfmt',
        'sleek',
        'stylua',
      },
    },
  },
}
