---@brief
---
--- https://github.com/withastro/language-tools/tree/main/packages/language-server
---
--- `astro-ls` can be installed via `npm`:
--- ```sh
--- npm install -g @astrojs/language-server
--- ```

---@type vim.lsp.Config
return {
  cmd = { 'astro-ls', '--stdio' },
  filetypes = { 'astro' },
  root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
  init_options = {
    typescript = {},
  },
  before_init = function(_, config)
    if config.init_options and config.init_options.typescript and not config.init_options.typescript.tsdk then
      local tsdk_path = ''
      local function find_typescript()
        local patterns = {
          'node_modules/typescript/lib',
          'node_modules/@typescript-language-server/node_modules/typescript/lib',
        }
        for _, pattern in ipairs(patterns) do
          local path = vim.fs.find(pattern, { upward = true, limit = 1 })[1]
          if path then
            return path
          end
        end
        return nil
      end
      if config.root_dir then
        local original_cwd = vim.fn.getcwd()
        vim.cmd('cd ' .. config.root_dir)
        tsdk_path = find_typescript() or ''
        vim.cmd('cd ' .. original_cwd)
      end
      if tsdk_path ~= '' then
        config.init_options.typescript.tsdk = tsdk_path
      end
    end
  end,
}
