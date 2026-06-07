# MacOS Dotfiles

Personal macOS configuration managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
# 1. Install Xcode CLI tools (if missing)
xcode-select --install

# 2. Clone repo
git clone https://github.com/T2Knock/dotfiles.git ~/dotfiles

# 3. Run setup script
cd ~/dotfiles && ./mac_setup.sh --confirm
```

The script handles:

- Homebrew installation (if missing)
- Package installation (formulae + casks)
- Fonts, stow symlinks, dev tools (fnm, rustup), zsh setup, tmux TPM

### Manual Steps (after script)

| Step             | Details                                                                               |
| ---------------- | ------------------------------------------------------------------------------------- |
| **Thorium**      | Download `.dmg` from [releases](https://github.com/Alex313031/Thorium-MacOS/releases) |
| **tmux plugins** | Open tmux, press `<prefix> + I`                                                       |
| **Neovim**       | Run `nvim --headless +'checkhealth' +qa`                                              |

## What's Included

### Shell & Terminal

| Tool            | Config                  | Notes                                                |
| --------------- | ----------------------- | ---------------------------------------------------- |
| **zsh** + zinit | `.config/zsh/`          | Plugin manager, autocompletions, syntax highlighting |
| **Ghostty**     | `.config/ghostty/`      | GPU-accelerated terminal                             |
| **tmux** + TPM  | `.config/tmux/`         | Terminal multiplexer with plugins                    |
| **starship**    | `.config/starship.toml` | Prompt                                               |

### Development

| Tool           | Config                | Notes                                |
| -------------- | --------------------- | ------------------------------------ |
| **neovim**     | `.config/nvim/`       | Lazy.nvim, native LSP (0.11+), Mason |
| **lazygit**    | `.config/lazygit/`    | Git TUI                              |
| **lazydocker** | `.config/lazydocker/` | Docker TUI                           |
| **GitHub CLI** | `gh`                  | Auth and PRs                         |

### CLI Tools

`fd`, `ripgrep`, `fzf`, `bat`, `eza`, `duf`, `dust`, `dua-cli`, `git-delta`, `zoxide`, `atuin`, `bottom`, `yazi`, `fastfetch`, `jq`, `imagemagick`, `ffmpeg`, `p7zip`, `fnm` (Node), `uv` (Python), `sesh`

## Structure

```
~/.config/
├── nvim/          # Neovim
├── zsh/           # Zsh (.zshrc, aliases, exports, functions)
├── tmux/          # Tmux
├── yazi/          # File manager
├── ghostty/       # Terminal
├── git/           # Git config
├── starship.toml  # Prompt
├── atuin/         # Shell history
├── bat/           # Cat with syntax highlighting
├── lazygit/       # Git TUI
├── lazydocker/    # Docker TUI
├── opencode/      # AI assistant
└── ...            # Other configs
```

## Design

- **macOS-only branch** — separate worktree from the Linux/Arch setup
- **GNU Stow** for symlink management — `stow -vt ~/.config .config` deploys all configs
- **No root** — everything runs as user
- **Standalone setup** — `mac_setup.sh` handles first-time provisioning

## Related

- [T2Knock/walle](https://github.com/T2Knock/walle) — wallpaper collection
- [T2Knock/JT-notes](https://github.com/T2Knock/JT-notes) — personal notes (Obsidian)
