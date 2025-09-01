#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

FONT_DIR="$HOME/.local/share/fonts"

echo -e "${GREEN}Installating fonts...${NC}"

if [[ ! -d "$FONT_DIR" ]]; then
    mkdir -p "$FONT_DIR"
fi

cp -rf fonts/* "$FONT_DIR"
fc-cache

echo -e "${GREEN}Starting package installation...${NC}"

sudo pacman -Syu --noconfirm

sudo pacman -S --needed --noconfirm \
    base-devel unzip curl wget git fastfetch openssh wl-clipboard \
    gcc clang go \
    neovim zsh ghostty rofi nautilus nwg-look \
    lazygit lazydocker \
    tmux ffmpeg p7zip jq poppler fzf \
    imagemagick stow \
    bottom starship eza duf dust git-delta dua-cli skim zoxide bat yazi fd ripgrep atuin bluetui nm-connection-editor nm-applet \
    hyprland hyprpolkitagent hyprshot hyprlock swww waybar swaync appimagelauncher

if ! command -v paru &>/dev/null; then
    echo -e "${GREEN}Installing paru...${NC}"
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
fi

# Install AUR packages
paru -S --needed --noconfirm \
    thorium-browser-avx2-bin \
    fnm uv \
    kanata \
    getnf tokyonight-gtk-theme-git

# Setup Node.js
echo -e "${GREEN}Installing Node.js LTS...${NC}"
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)" 2>/dev/null || true
fnm install --lts
fnm use lts-latest 2>/dev/null || true

# Setup kanata properly
echo -e "${GREEN}Setting up kanata...${NC}"

sudo groupadd uinput
sudo usermod -aG input "$USER"
sudo usermod -aG uinput "$USER"

sudo tee /etc/udev/rules.d/99-uinput.rules >/dev/null <<'EOF'
KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger
sudo modprobe uinput

systemctl --user daemon-reload
systemctl --user enable kanata.service

echo -e "${GREEN}Installation complete!${NC}"
