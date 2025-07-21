# dotfiles

My own dot files ( picking up idea from different places work for me tho)

![Themes](screenshot.png)

## Setup Script

This repository includes a `setup_machine.sh` script to automate the installation of necessary packages, deployment of dotfiles using `stow`, and setup of various development tools and shell enhancements.

**Usage:**

```bash
./setup_machine.sh
```

**What it does:**

- Updates system package lists.
- Installs `stow` for dotfile management.
- Deploys dotfiles from the `.config` directory to `~/.config` using `stow`.
- Installs core system packages (development tools, window manager components, desktop utilities) via `apt`.
- Installs Rust, Go, and Node.js based tools.
- Sets up Zsh with Zinit.
- Installs JetBrains Mono Nerd Font.
- Installs Papirus icon theme.
- Updates shell paths.

**Post-setup steps:**

1. Restart your terminal or run: `source ~/.zshrc`
2. Set Zsh as default shell: `chsh -s $(which zsh)`
3. Log out and back in to apply all changes.
4. Configure your desktop wallpaper with `nitrogen`.
5. Use `lxappearance` to set your theme and select Papirus icons.
6. Your JetBrains Mono Nerd Font is ready for terminal use.

## Themes and Fonts

- Jetbrains Mono (inspired by syntax fm)

## Package Requires

- [Neovim](https://neovim.io/)
- [alacritty](https://github.com/alacritty/alacritty)
- [tmux](https://github.com/tmux/tmux)
- [I3 ( latest version )](https://i3wm.org/)
- [I3-status-rust](https://github.com/greshake/i3status-rust)
- [I3lock-color](https://github.com/Raymo111/i3lock-color)
- [dunst](https://github.com/dunst-project/dunst)
- [Rofi](https://github.com/davatorium/rofi)
- [Picom](https://github.com/yshui/picom)
- [feh](https://feh.finalrewind.org/)
- [lxappearance](https://github.com/lxde/lxappearance)
- [arandr](https://github.com/haad/arandr)
- [pavucontrol](https://freedesktop.org/software/pulseaudio/pavucontrol/)
- [maim](https://github.com/naelstrof/maim)
