# Neovim configuration

`init.lua` loads `config.options`, `config.lazy`, `config.lsp`,
`config.keymaps`, and `config.autocommands`.

The configuration uses lazy.nvim for plugins, Mason and nvim-lspconfig for
language servers, and stylua for formatting. It uses the Neovim 0.11
`vim.lsp.config` and `vim.lsp.enable` API. nvim-lspconfig supplies the server
defaults, and an override deep-merges with them.

## Layout

```text
lua/config/     core modules
lua/plugins/    plugin specs
lua/adapters/   language server adapters
snippets/       snippets
spell/          spell files
```

## Style

Format with stylua. `.stylua.toml` sets 160 columns, two spaces, Unix line
endings, `AutoPreferSingle` quotes, and `call_parentheses = "None"`.

Use `snake_case` for modules, functions, and variables, and
`SCREAMING_SNAKE_CASE` for constants. A module returns a local table:

```lua
local M = {}

function M.setup() end

return M
```

Add LuaCATS annotations to LSP configs and public functions. Use `pcall` for
operations that can fail and `vim.uv` for filesystem calls.

## LSP

Server overrides live in `lua/config/lsp.lua`. Add an override with
`vim.lsp.config('name', { ... })` and enable a server with
`vim.lsp.enable 'name'`.

Mason installs the servers. `mason-lspconfig` enables them automatically except
`tsgo`, `ts_ls`, `rumdl`, `harper_ls`, and `oxfmt`.

Use `root_markers` or `vim.fs.root()` for root detection. Pass settings through
`vim.lsp.config` instead of requiring `lspconfig.util`. Check features that need
a newer Neovim with `vim.fn.has 'nvim-0.11.3'`.

## Checks

```bash
cd .config/nvim
stylua --check .
nvim --headless +'checkhealth' +qa
nvim --headless +'lua vim.lsp.enable({"lua_ls", "gopls"})' +qa
luac -p <file>
```

To check that a server attaches:

```bash
nvim --headless \
  -c 'lua vim.lsp.enable({"lua_ls"})' \
  -c 'edit /tmp/test.lua' \
  -c 'sleep 2' \
  -c 'lua print(#vim.lsp.get_clients())' \
  -c 'qa'
```
