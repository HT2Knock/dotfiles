return {
  {
    'mason-org/mason.nvim',
    opts = {},
    dependencies = {
      {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        opts = {
          ensure_installed = {
            -- lsp
            'lua-language-server',
            'stylua',
            'typescript-language-server',
            'astro-language-server',
            'tailwindcss-language-server',
            'gopls',
            'harper-ls',
            'ruff',
            'taplo',
            'bash-language-server',
            'yaml-language-server',
            'json-lsp',
            'eslint-lsp',
            'postgres-language-server',
            'css-lsp',

            -- dap
            'delve',
            'debugpy',
            'js-debug-adapter',

            -- linter
            'shellcheck',
            'golangci-lint',
            'rumdl',

            -- formatter
            'prettier',
            'gofumpt',
            'goimports',
            'shfmt',
            'sleek',
          },
        },
      },
    },
  },
}
