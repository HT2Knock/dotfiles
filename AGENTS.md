# Dotfiles Repository - Agent Guidelines

This is a **dotfiles repository** managed with [GNU Stow](https://www.gnu.org/software/stow/). Configurations are organized per application and symlinked to `$HOME` using stow.

## Repository Structure

```
dotfiles/
├── .config/
│   ├── nvim/          # Neovim configuration
│   ├── zsh/           # Zsh shell configuration
│   ├── hypr/          # Hyprland window manager
│   ├── tmux/          # Tmux terminal multiplexer
│   ├── yazi/          # Yazi file manager
│   ├── opencode/      # OpenCode AI assistant
│   ├── starship.toml  # Starship prompt
│   └── ...            # Other tool configs
├── scripts/           # Utility shell scripts
├── fonts/             # Custom fonts
├── assets/            # Images, themes, etc.
└── arch_post_install.sh  # Arch Linux setup script
```

## Build/Lint/Test Commands

### Deploying Configurations (Stow)
```bash
# Stow a single package (symlinks to $HOME)
stow -t ~ .config/nvim

# Restow (update symlinks)
stow -R -t ~ .config/nvim

# Delete symlinks
stow -D -t ~ .config/nvim

# Simulate without making changes
stow -n -t ~ .config/nvim
```

### Lua Formatting (Neovim configs)
```bash
# Format all Lua files in nvim config
cd .config/nvim && stylua .

# Check formatting without modifying
stylua --check .

# Format specific file
stylua .config/nvim/lua/config/options.lua
```

### Shell Script Linting
```bash
# Check shell scripts with shellcheck (if installed)
shellcheck scripts/*.sh
shellcheck .config/zsh/*.zsh

# Validate bash syntax
bash -n arch_post_install.sh
```

### Neovim Health Check
```bash
# Check Neovim configuration health
nvim --headless +'checkhealth' +qa

# Verify LSP configs load
nvim --headless +'lua vim.lsp.enable({"lua_ls", "gopls"})' +qa

# Quick Lua syntax check
luac -p .config/nvim/lua/config/options.lua
```

### Testing Changes
```bash
# Test zsh config loads without errors
zsh -i -c 'echo "Zsh config OK"'

# Test tmux config
tmux -f .config/tmux/tmux.conf start-server \; kill-server

# Validate JSON configs
python3 -m json.tool .config/swaync/config.json > /dev/null

# Validate YAML configs
python3 -m yaml .config/lazygit/config.yml 2>/dev/null || yamllint .config/lazygit/config.yml

# Validate TOML configs
tomllint .config/starship.toml
```

## Code Style Guidelines

### Shell Scripts (Bash/Zsh)

**Shebang and Options:**
```bash
#!/usr/bin/env bash
set -euo pipefail  # Exit on error, undefined var, pipe failure
```

**Naming Conventions:**
- Variables: `snake_case` (lowercase)
- Constants: `SCREAMING_SNAKE_CASE`
- Functions: `snake_case`
- Local variables: use `local` keyword

**Example:**
```bash
#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="$HOME/install.log"

log() {
    local level="$1"
    shift
    local message="$*"
    echo "[$level] $message" >> "$LOG_FILE"
}

main() {
    local config_file=""
    config_file="$SCRIPT_DIR/config.conf"
    # ...
}
```

**Error Handling:**
- Use `set -euo pipefail` at the top
- Check command success with `if` or `||`
- Use `readonly` for constants
- Quote all variable expansions: `"$var"`

### Lua (Neovim Configuration)

See `.config/nvim/AGENTS.md` for detailed Lua guidelines. Key points:

- **Formatter**: stylua (config in `.config/nvim/.stylua.toml`)
- **Indent**: 2 spaces
- **Line width**: 160 characters
- **Quotes**: Prefer single quotes (`AutoPreferSingle`)
- **Naming**: `snake_case` for functions/variables, `SCREAMING_SNAKE_CASE` for constants
- **Types**: Use LuaLS annotations (`---@type vim.lsp.Config`)

### Configuration Files

**JSON:**
- Use 2 space indentation
- Keep single quotes in strings (JSON requires double quotes)
- Validate before committing

**YAML:**
- Use 2 space indentation
- Avoid tabs (YAML doesn't allow them)
- Quote strings with special characters

**TOML:**
- Use inline tables for simple data
- Group related settings under section headers
- Use dot notation for nested tables when appropriate

**Example TOML (starship.toml style):**
```toml
[format]
src = """
  $username\
  $directory\
"""

[git_branch]
symbol = " "
```

### Zsh Configuration

**File Organization:**
- `.zshrc` - Main entry point
- `zsh-aliases` - Command aliases
- `zsh-exports` - Environment variables
- `zsh-functions` - Custom functions

**Style:**
```zsh
# Aliases: lowercase with descriptive names
alias lg="lazygit"
alias v='nvim'

# Exports: UPPERCASE
export EDITOR='nvim'
export BROWSER='firefox'

# Functions: snake_case
my_function() {
    local var="value"
    # ...
}
```

## Important Rules

1. **Stow packages**: Each app config must be in its own directory under `.config/` or similar
2. **No secrets**: Never commit API keys, tokens, or passwords (see `.gitignore`)
3. **Symlink safety**: Use `stow -n` to simulate before actual deployment
4. **Config validation**: Always validate JSON/YAML/TOML before committing
5. **Shell portability**: Use `#!/usr/bin/env bash` not `/bin/bash` for portability
6. **Neovim LSP**: Uses native LSP (0.11+), NOT nvim-lspconfig plugin

## File Ignore Patterns

Defined in `.stow-local-ignore`:
- `colors/` directory (except `astronvim.lua`)
- `*.null-ls*` files
- `lua/user/` directory
- `ftplugin/` directory
- `.luarc.json`, `.gitignore` specific to nested dirs

## Plugin Management

- **Neovim**: Uses lazy.nvim (config in `.config/nvim/lua/config/lazy.lua`)
- **Zsh**: Uses zinit (loaded in `.zshrc`)
- **Tmux**: Uses TPM (Tmux Plugin Manager)

## Testing Workflow

1. Make changes to config files
2. Run appropriate linter/formatter
3. Test by restarting/reloading the application
4. For stow-managed configs: `stow -R -t ~ <package>` to update symlinks
5. Verify application loads without errors
