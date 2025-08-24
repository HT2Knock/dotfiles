#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Starting package installation...${NC}"

# Update system first
sudo pacman -Syu --noconfirm

# Install official packages
sudo pacman -S --needed --noconfirm \
  base-devel unzip curl wget git fastfetch openssh wl-clipboard \
  gcc clang go \
  neovim zsh ghostty \
  lazygit lazydocker \
  tmux ffmpeg p7zip jq poppler fzf \
  imagemagick stow \
  bottom starship eza duf dust git-delta dua-cli skim zoxide bat yazi fd ripgrep atuin

# Check if paru exists, install if not
if ! command -v paru &> /dev/null; then
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
    kanata

# Setup Node.js
echo -e "${GREEN}Installing Node.js LTS...${NC}"
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)" 2>/dev/null || true
fnm install --lts
fnm use lts-latest 2>/dev/null || true

# Setup kanata properly
echo -e "${GREEN}Setting up kanata...${NC}"

# Create uinput group and add user to both groups
sudo groupadd uinput
sudo usermod -aG input "$USER"
sudo usermod -aG uinput "$USER"

# Add udev rule for uinput permissions
sudo tee /etc/udev/rules.d/99-uinput.rules >/dev/null << 'EOF'
KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
EOF

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo modprobe uinput

# Enable system control for kanata
systemctl --user daemon-reload
systemctl --user enable kanata.service

echo -e "${GREEN}Installation complete!${NC}"
