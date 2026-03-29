# Neovim Configuration - Agent Guidelines

This is a Neovim configuration repository. It uses:
- **Lazy.nvim** for plugin management
- **Native Neovim LSP** (0.11+) with custom configs in `lsp/`
- **stylua** for Lua formatting

## Build/Lint/Test Commands

### Lua Formatting (stylua)
```bash
# Format all Lua files
stylua .

# Check formatting without modifying
stylua --check .

# Format specific file
stylua lua/config/options.lua
```

### Python Linting (ruff) - For any Python scripts
```bash
ruff check .
ruff check --fix .
```

### Neovim Health Check
```bash
nvim --headless +'checkhealth' +qa
```

### LSP Config Validation
```bash
# Verify all LSP configs load
nvim --headless +'lua vim.lsp.enable({"lua_ls", "gopls"})' +qa

# Check Lua syntax
luac -p lsp/astro.lua

# Test LSP attachment with a file
nvim --headless \
  -c 'lua vim.lsp.enable({"lua_ls"})' \
  -c 'edit /tmp/test.lua' \
  -c 'sleep 1' \
  -c 'lua print(vim.inspect(vim.lsp.get_active_clients()))' \
  -c 'qa'
```

## Code Style Guidelines

### Lua Formatting (stylua)
Settings in `.stylua.toml`:
- Column width: 160
- Indent: 2 spaces
- Quote style: AutoPreferSingle
- Call parentheses: None (optional)
- Line endings: Unix

### Naming Conventions
| Type | Convention | Example |
|------|------------|---------|
| Modules | `snake_case` | `config.options` |
| Functions | `snake_case` | `setup_lsp()` |
| Variables | `snake_case` | `local config = {}` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_RETRIES` |
| Class-like tables | `PascalCase` | `local M = {}` |

### Imports
```lua
-- Neovim modules
require 'config.options'

-- Local imports
local mod = require 'module'
local helpers = require 'utils.helpers'

-- Prefer local over global
local vim = vim
```

### Error Handling
```lua
-- Use pcall for potentially failing operations
local ok, result = pcall(vim.fn.readfile, path)
if not ok then return end

-- Use vim.uv for LuaJIT compatible file operations
if vim.uv.fs_stat(path) then
  -- file exists
end

-- Handle nil gracefully
if value and value.field then
  -- safe to access
end
```

### Types
Use vimscript annotations for clarity:
```lua
---@type vim.lsp.Config
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
}
```

## LSP Configuration (lsp/)

This uses **native Neovim LSP 0.11+**, NOT nvim-lspconfig.

### Structure
Each file in `lsp/` returns a config table:
```lua
---@type vim.lsp.Config
return {
  cmd = { 'server-name', '--stdio' },
  filetypes = { 'filetype' },
  root_markers = { 'package.json', '.git' },
  -- or
  root_dir = function(bufnr, on_dir)
    on_dir(vim.fs.root(bufnr, { '.git' }))
  end,

  -- Optional
  settings = {},
  init_options = {},
  capabilities = {},
  workspace_required = true,
  before_init = function(_, config) end,
  on_attach = function(client, bufnr) end,
  on_init = function(client) end,
  handlers = {},
}
```

### Important Rules
1. **Do NOT** use `require 'lspconfig.util'` - implement inline
2. **Do NOT** use `---@type lspconfig.settings.*` annotations (lspconfig not installed)
3. Keep configs self-contained without external dependencies
4. Use `vim.fs.root()` for root directory detection
5. Use `vim.fn.has 'nvim-0.11.3'` for Neovim version checks

## File Organization

```
nvim/
├── init.lua              # Entry point
├── lua/
│   ├── config/          # Core configuration
│   │   ├── options.lua  # vim.o settings
│   │   ├── keymaps.lua  # Keybindings
│   │   ├── lazy.lua     # Plugin manager
│   │   ├── lsp.lua      # LSP enable/servers
│   │   └── autocmds.lua # Autocommands
│   ├── plugins/         # Plugin configs
│   └── adapters/        # LSP adapters
├── lsp/                 # LSP server configs (native 0.11+)
├── snippets/            # Text snippets
└── spell/               # Spell files
```

## Testing Changes

### Quick Syntax Check
```bash
luac -p lua/config/options.lua
```

### Full LSP Test
```bash
# Create test file
echo 'local x = 1' > /tmp/test.lua

# Open in headless nvim with LSP
nvim --headless \
  -c 'lua vim.lsp.enable({"lua_ls"})' \
  -c 'edit /tmp/test.lua' \
  -c 'sleep 2' \
  -c 'lua print(#vim.lsp.get_active_clients())' \
  -c 'qa'

# Clean up
rm /tmp/test.lua
```

### Plugin Health
```bash
nvim --headless +'lua vim.health.report()' +qa
```
