---@brief
---
--- https://github.com/tailwindlabs/tailwindcss-intellisense
---
--- Tailwind CSS Language Server can be installed via npm:
---
--- npm install -g @tailwindcss/language-server

local function insert_package_json(root_files, field, fname)
  local package_json_path = vim.fs.find('package.json', {
    path = fname,
    upward = true,
    limit = 1,
  })[1]

  if not package_json_path then
    return root_files
  end

  local ok, content = pcall(vim.fn.readfile, package_json_path)
  if not ok then
    return root_files
  end

  local json_ok, data = pcall(vim.json.decode, table.concat(content, '\n'))
  if json_ok and data[field] ~= nil then
    local result = vim.list_extend({}, root_files)
    table.insert(result, 'package.json')
    return result
  end

  return root_files
end

local function root_markers_with_field(root_files, lock_files, field, fname)
  local result = vim.list_extend({}, root_files)

  for _, lock_file in ipairs(lock_files) do
    local lock_path = vim.fs.find(lock_file, {
      path = fname,
      upward = true,
      limit = 1,
    })[1]

    if lock_path then
      local pkg_json = vim.fs.find('package.json', {
        path = fname,
        upward = true,
        limit = 1,
      })[1]

      if pkg_json then
        local ok, content = pcall(vim.fn.readfile, pkg_json)
        if ok then
          local json_ok, data = pcall(vim.json.decode, table.concat(content, '\n'))
          if json_ok and data[field] ~= nil then
            table.insert(result, lock_file)
            break
          end
        end
      end
    end
  end

  return result
end

---@type vim.lsp.Config
return {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = {
    'aspnetcorerazor',
    'astro',
    'astro-markdown',
    'blade',
    'clojure',
    'django-html',
    'htmldjango',
    'edge',
    'eelixir',
    'elixir',
    'ejs',
    'erb',
    'eruby',
    'gohtml',
    'gohtmltmpl',
    'haml',
    'handlebars',
    'hbs',
    'html',
    'htmlangular',
    'html-eex',
    'heex',
    'jade',
    'leaf',
    'liquid',
    'markdown',
    'mdx',
    'mustache',
    'njk',
    'nunjucks',
    'php',
    'razor',
    'slim',
    'twig',
    'css',
    'less',
    'postcss',
    'sass',
    'scss',
    'stylus',
    'sugarss',
    'javascript',
    'javascriptreact',
    'reason',
    'rescript',
    'typescript',
    'typescriptreact',
    'vue',
    'svelte',
    'templ',
  },
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
  settings = {
    tailwindCSS = {
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
      classAttributes = {
        'class',
        'className',
        'class:list',
        'classList',
        'ngClass',
      },
      includeLanguages = {
        eelixir = 'html-eex',
        elixir = 'phoenix-heex',
        eruby = 'erb',
        heex = 'phoenix-heex',
        htmlangular = 'html',
        templ = 'html',
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
      'tailwind.config.js',
      'tailwind.config.cjs',
      'tailwind.config.mjs',
      'tailwind.config.ts',
      'postcss.config.js',
      'postcss.config.cjs',
      'postcss.config.mjs',
      'postcss.config.ts',
      'theme/static_src/tailwind.config.js',
      'theme/static_src/tailwind.config.cjs',
      'theme/static_src/tailwind.config.mjs',
      'theme/static_src/tailwind.config.ts',
      'theme/static_src/postcss.config.js',
      '.git',
    }
    local fname = vim.api.nvim_buf_get_name(bufnr)
    root_files = insert_package_json(root_files, 'tailwindcss', fname)
    root_files = root_markers_with_field(root_files, { 'mix.lock', 'Gemfile.lock' }, 'tailwind', fname)
    on_dir(vim.fs.dirname(vim.fs.find(root_files, { path = fname, upward = true })[1]))
  end,
}
