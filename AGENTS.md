# Dotfiles repository

This repository holds personal configuration files. GNU Stow links them into
`~/.config`.

## Instruction precedence

Apply every relevant instruction file. When two conflict, use this order:

1. The user's explicit instruction.
2. The nearest app `AGENTS.md`, such as `.config/nvim/AGENTS.md`.
3. This file.

Put app-specific rules in that app's `AGENTS.md`, next to the code they govern.
Keep each instruction file short.

## Stow

The repository is one Stow package, `.config`, with target `~/.config`.

```bash
stow -n -v -t ~/.config .config
stow -t ~/.config .config
stow -R -t ~/.config .config
```

The first command shows the change. The second applies it. The third rebuilds
links after a move or rename.

Stow rejects a package name with a slash, so `stow -t ~ .config/nvim` fails. To
act on one app, use `-d .config`:

```bash
stow -d .config -t ~/.config nvim
```

## Verification by change type

Use the narrowest check that covers the change. Run it before you commit.

| Change                                         | Check                                                                       |
| ---------------------------------------------- | --------------------------------------------------------------------------- |
| Neovim Lua (`.config/nvim/**/*.lua`)           | `cd .config/nvim && stylua --check .`                                       |
| Neovim config load                             | `nvim --headless +'checkhealth' +qa`                                        |
| LSP config (`.config/nvim/lua/config/lsp.lua`) | `nvim --headless +'lua vim.lsp.enable({"lua_ls", "gopls"})' +qa`            |
| Single Lua file syntax                         | `luac -p <file>`                                                            |
| Rex Lua (`.config/rex/**/*.lua`)               | `cd .config/rex && stylua --check .`, then `rex config check`               |
| Rex bindings                                   | `rex keymap`                                                                |
| Shell scripts (`scripts/*.sh`, `mac_setup.sh`) | `bash -n <file>`, then `shellcheck <file>` when installed                   |
| Zsh (`.config/zsh/**`)                         | `zsh -n .config/zsh/zsh-functions`, then `zsh -i -c 'echo "Zsh config OK"'` |
| tmux (`.config/tmux/tmux.conf`)                | `tmux -f .config/tmux/tmux.conf start-server \; kill-server`                |
| JSON                                           | `python3 -m json.tool <file> > /dev/null`                                   |
| YAML                                           | `python3 -m yaml <file> 2>/dev/null` or `yamllint <file>`                   |
| TOML                                           | `tomllint <file>`                                                           |
| New or renamed Stow app                        | `stow -n -v -t ~/.config .config`, then `stow -t ~/.config .config`         |
| Aerospace, Ghostty, themes                     | Reload the application and check it visually. No headless check exists.     |

## Generated files

`~/.config/<app>` is a symlink that Stow generates. The repository file is the
source of truth.

Edit the repository file. Do not edit through the symlink with a tool that
replaces the file, because the replacement breaks the link.

Run `stow -R` after a move or rename. Do not copy files into `~/.config` by
hand. Do not commit caches or runtime state; `.gitignore` lists them.

## Code style

### Shell scripts

Start Bash scripts with:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Use `snake_case` for variables and functions, `SCREAMING_SNAKE_CASE` for
constants, and `local` for local variables. Quote every expansion. Use
`readonly` for constants. Check success with `if` or `||`.

### Lua

`.config/nvim/AGENTS.md` owns the Lua rules. Format with stylua from
`.config/nvim/.stylua.toml`. Use two spaces, 160 columns, and single quotes. Use
`snake_case` for functions and variables, `SCREAMING_SNAKE_CASE` for constants,
and LuaCATS annotations.

### Configuration files

Use a two-space indent for JSON and YAML. Validate JSON with
`python3 -m json.tool` and YAML with `yamllint`. Use inline TOML tables for
short data and sections for groups.

### Zsh

`.zshrc` is the entry point. `zsh-aliases` holds aliases, `zsh-exports` holds
environment variables, and `zsh-functions` holds functions. Use lowercase
aliases, uppercase exports, and `snake_case` function names.

## Hard rules

- Run `stow -n` first when a change adds, moves, or removes links.
- Stage explicit paths with `git add <path1> <path2>`. Never run `git add -A` or
  `git add .`, because they stage files you did not review. Never run
  `git reset --hard`, `git clean -fd`, or `git stash`, because they destroy or
  hide uncommitted work.
- Keep API keys, tokens, and passwords out of commits. See `.gitignore`.
- Edit the source of a generated file, not the generated file.
- Start Bash scripts with `#!/usr/bin/env bash`. The macOS system Bash is
  version 3.2.

## Git

Run `git status` before each commit and confirm that only your files are staged.
Keep one logical change per commit, with a short message.

## Plugins

Plugin managers: lazy.nvim in `.config/nvim/lua/config/lazy.lua`, zinit in
`.zshrc`, and TPM for tmux.
