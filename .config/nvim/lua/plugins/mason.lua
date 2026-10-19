return {
  {
    'mason-org/mason.nvim',
    opts = {},
  },
  {
    'mason-org/mason-lspconfig.nvim',
    opts = {
      automatic_enable = {
        exclude = { 'tsgo', 'ts_ls', 'rumdl', 'harper_ls', 'oxfmt' },
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
        'oxlint',
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
        'oxfmt',
        'prettier', -- astro only: oxfmt has no Astro support
        'gofumpt',
        'goimports',
        'shfmt',
        'sleek',
        'stylua',
      },
    },
  },
}
