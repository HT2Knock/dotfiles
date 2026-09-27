# Dotfiles Repository - Agent Guidelines

This repository stores personal configuration files for GNU Stow. Each application
directory under `.config/` is a Stow package. Stow links package files into `~/.config`.

## Instruction precedence

Apply every relevant instruction file. If two instructions conflict, resolve them
in this order:

1. Explicit instructions from the user.
2. The nearest app `AGENTS.md`, for example `.config/nvim/AGENTS.md` or
   `.config/opencode/AGENTS.md`.
3. This file.

This file holds shared rules only. Put app-specific rules in that app's `AGENTS.md`,
next to the code they govern.

## Repository structure

- `.config/<app>/` — one Stow package per application.
- `scripts/` — utility shell scripts.
- `fonts/` — custom fonts.
- `assets/` — images, themes, and agent snippets.
- `mac_setup.sh` — macOS setup script.
- `README.md` — repository overview.
- `.stow-local-ignore` — the Stow ignore list. This file is authoritative.
- `.gitignore` — the Git ignore list. This file is authoritative.

Run `ls` for the current list. The directories are the source of truth; this map is
an overview only.

## Deploying configurations (Stow)

The repository is stowed as a single package, `.config`, with target `~/.config`.

```bash
# Show what Stow would change, without changing it
stow -n -v -t ~/.config .config

# Create or update links for every app
stow -t ~/.config .config

# Re-create links after moving or renaming files
stow -R -t ~/.config .config

# Act on one app only: point the Stow directory at .config
stow -d .config -t ~/.config nvim
stow -R -d .config -t ~/.config nvim
stow -D -d .config -t ~/.config nvim
```

Stow rejects a package name that contains a slash, so `stow -t ~ .config/nvim` fails.
Use the `.config` package form, or `-d .config` to act on one app.

## Verification by change type

Use the narrowest check that covers the change. Run it before you commit.

| Change | Check |
| --- | --- |
| Neovim Lua (`.config/nvim/**/*.lua`) | `cd .config/nvim && stylua --check .` |
| Neovim config load | `nvim --headless +'checkhealth' +qa` |
| LSP config (`.config/nvim/lsp/*.lua`) | `nvim --headless +'lua vim.lsp.enable({"lua_ls", "gopls"})' +qa` |
| Single Lua file syntax | `luac -p <file>` |
| Shell scripts (`scripts/*.sh`, `mac_setup.sh`) | `bash -n <file>`, then `shellcheck <file>` when installed |
| Zsh (`.config/zsh/**`) | `zsh -i -c 'echo "Zsh config OK"'` |
| tmux (`.config/tmux/tmux.conf`) | `tmux -f .config/tmux/tmux.conf start-server \; kill-server` |
| JSON | `python3 -m json.tool <file> > /dev/null` |
| YAML | `python3 -m yaml <file> 2>/dev/null` or `yamllint <file>` |
| TOML | `tomllint <file>` |
| New or renamed Stow app | `stow -n -v -t ~/.config .config`, then `stow -t ~/.config .config` |
| Aerospace, Ghostty, themes | Reload the running application and check it visually. No headless check exists. |

## Generated artifacts

`~/.config/<app>` is a symlink that Stow generates from this repository. The file in
the repository is the source of truth.

- Edit the file in the repository. Do not edit through the symlink with a tool that
  replaces the file, because replacement breaks the link.
- Rebuild links after moving or renaming files: `stow -R -t ~/.config .config`.
- Do not copy files into `~/.config` by hand. Copies drift from the repository.
- Do not commit caches or runtime state. See `.gitignore` for the list.

## Code style

### Shell scripts (Bash and Zsh)

```bash
#!/usr/bin/env bash
set -euo pipefail
```

- Variables and functions: `snake_case`. Constants: `SCREAMING_SNAKE_CASE`.
- Declare local variables with `local`.
- Quote all variable expansions: `"$var"`.
- Use `readonly` for constants.
- Check command success with `if` or `||`.

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="$HOME/install.log"

log() {
    local level="$1"
    shift
    echo "[$level] $*" >> "$LOG_FILE"
}
```

### Lua (Neovim configuration)

`.config/nvim/AGENTS.md` owns the detailed Lua rules. Key points:

- Format with stylua, configured in `.config/nvim/.stylua.toml`.
- Indent with 2 spaces, column width 160, single quotes.
- Functions and variables: `snake_case`. Constants: `SCREAMING_SNAKE_CASE`.
- Add LuaLS annotations, for example `---@type vim.lsp.Config`.

### Configuration files

- JSON: 2-space indent. Validate with `python3 -m json.tool`.
- YAML: 2-space indent, no tabs. Validate with `yamllint`.
- TOML: inline tables for short data, section headers for groups.

### Zsh configuration

- `.zshrc` is the entry point.
- `zsh-aliases` holds aliases, `zsh-exports` holds environment variables, and
  `zsh-functions` holds functions.
- Aliases: lowercase and descriptive. Exports: uppercase. Functions: `snake_case`.

## Hard prohibitions

- Never run `stow` without `-n` first when the change adds, moves, or removes links.
  The simulation shows the result before it happens.
- Never run `git add -A`, `git add .`, `git reset --hard`, `git clean -fd`, or
  `git stash`. These commands destroy uncommitted work.
- Never commit API keys, tokens, or passwords. See `.gitignore`.
- Never hand-edit a generated file when its generator or source exists.
- Never use `#!/bin/bash`. Use `#!/usr/bin/env bash`, because the macOS system Bash
  is version 3.2.

## Git

- Stage explicit paths: `git add <path1> <path2>`.
- Run `git status` before each commit and confirm that only your files are staged.
- Keep one logical change per commit, with a short message.

## Plugins

- Neovim: lazy.nvim, in `.config/nvim/lua/config/lazy.lua`.
- Zsh: zinit, loaded in `.zshrc`.
- tmux: TPM.
