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
            'gopls',
            'marksman',
            'ruff',
            'taplo',
            'bash-language-server',
            'yaml-language-server',
            'eslint-lsp',
            'postgrestools',

            -- dap
            'delve',
            'debugpy',
            'js-debug-adapter',

            -- linter
            'shellcheck',
            'golangci-lint',
            'markdownlint-cli2',

            -- formatter
            'prettierd',
            'gofumpt',
            'goimports',
            'shfmt',
          },
        },
      },
    },
  },
}
