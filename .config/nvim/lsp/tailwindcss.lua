return {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue',
    'astro',
    'svelte',
    'html',
    'blade',
    'css',
    'scss',
  },
  settings = {
    tailwindCSS = {
      emmetCompletions = true,
      validate = true,
      lint = {
        cssConflict = 'warning',
        invalidApply = 'error',
        invalidScreen = 'error',
        invalidVariant = 'error',
        invalidConfigPath = 'error',
        invalidTailwindDirective = 'error',
        recommendedVariantOrder = 'warning',
      },
      -- Tailwind class attributes configuration
      classAttributes = { 'class', 'className', 'classList', 'ngClass', ':class' },

      -- Experimental regex patterns to detect Tailwind classes in various syntaxes
      experimental = {
        classRegex = {
          -- tw`...` or tw("...")
          'tw`([^`]*)`',
          'tw\\(([^)]*)\\)',

          -- @apply directive inside SCSS / CSS
          '@apply\\s+([^;]*)',

          -- class and className attributes (HTML, JSX, Vue, Blade with :class)
          'class="([^"]*)"',
          'className="([^"]*)"',
          ':class="([^"]*)"',

          -- Laravel @class directive e.g. @class([ ... ])
          '@class\\(([^)]*)\\)',
        },
      },
    },
  },
  before_init = function(_, config)
    if not config.settings then
      config.settings = {}
    end
    if not config.settings.editor then
      config.settings.editor = {}
    end
    if not config.settings.editor.tabSize then
      config.settings.editor.tabSize = vim.lsp.util.get_effective_tabstop()
    end
  end,
  workspace_required = true,
  root_dir = function(bufnr, on_dir)
    local root_files = {
      -- Generic
      'tailwind.config.js',
      'tailwind.config.cjs',
      'tailwind.config.mjs',
      'tailwind.config.ts',
      'postcss.config.js',
      'postcss.config.cjs',
      'postcss.config.mjs',
      'postcss.config.ts',
    }
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(vim.fs.dirname(vim.fs.find(root_files, { path = fname, upward = true })[1]))
  end,
}
