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
            'marksman',
            'ruff',
            'taplo',
            'bash-language-server',
            'yaml-language-server',
            'json-lsp',
            'eslint-lsp',
            'postgrestools',
            'css-lsp',

            -- dap
            'delve',
            'debugpy',
            'js-debug-adapter',

            -- linter
            'shellcheck',
            'golangci-lint',
            'markdownlint-cli2',

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
