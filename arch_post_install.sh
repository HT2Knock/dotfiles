#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="$HOME/arch-install.log"
readonly FONT_DIR="$HOME/.local/share/fonts"

readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case "$level" in
    "INFO") echo -e "${GREEN}[INFO]${NC} $message" ;;
    "WARN") echo -e "${YELLOW}[WARN]${NC} $message" ;;
    "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
    "DEBUG") echo -e "${BLUE}[DEBUG]${NC} $message" ;;
    esac

    echo "[$timestamp] [$level] $message" >>"$LOG_FILE"
}

error_exit() {
    log "ERROR" "$1"
    exit 1
}

check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        error_exit "This script should not be run as root"
    fi
}

install_fonts() {
    log "INFO" "Installing fonts..."

    if [[ ! -d "$SCRIPT_DIR/fonts" ]]; then
        log "WARN" "Fonts directory not found, skipping font installation"
        return 0
    fi

    mkdir -p "$FONT_DIR"
    cp -rf "$SCRIPT_DIR/fonts/"* "$FONT_DIR/" 2>/dev/null || {
        log "WARN" "Failed to copy fonts, continuing..."
        return 0
    }

    fc-cache -fv
    log "INFO" "Fonts installed successfully"
}

update_system() {
    log "INFO" "Updating system packages..."
    sudo pacman -Syu --noconfirm || error_exit "Failed to update system"
}

install_official_packages() {
    log "INFO" "Installing official packages..."

    local packages=(
        # Base development tools
        base-devel unzip curl wget git openssh

        # System utilities
        fastfetch imv wl-clipboard p7zip jq poppler fzf imagemagick stow

        # Input Method
        fcitx5-im fcitx5-bamboo

        # Development tools
        gcc clang go rustup neovim tmux docker docker-compose

        # Shell and terminal
        zsh ghostty

        # File management
        nautilus yazi fd ripgrep

        # Modern CLI tools
        starship eza duf dust git-delta dua-cli zoxide bat atuin bottom

        # Git tools
        lazygit lazydocker github-cli

        # Media
        ffmpeg

        # Network tools
        bluetui nm-connection-editor network-manager-applet

        # Hyprland ecosystem
        hyprland hyprpolkitagent hyprshot hyprlock hypridle hyprsunset
        swww waybar swaync xdg-desktop-portal-hyprland sddm

        # QT
        qt5-wayland qt6-wayland kvatum qt5ct qt6ct

        # Application launcher and utilities
        nwg-look fuzzel cliphist wtype

        # Document viewer
        zathura zathura-pdf-mupdf
    )

    sudo pacman -S --needed "${packages[@]}" || error_exit "Failed to install official packages"
    log "INFO" "Official packages installed successfully"
}

install_paru() {
    if command -v paru &>/dev/null; then
        log "INFO" "Paru already installed, skipping..."
        return 0
    fi

    log "INFO" "Installing paru AUR helper..."
    local temp_dir="/tmp/paru-install-$$"

    mkdir -p "$temp_dir"
    cd "$temp_dir"

    git clone https://aur.archlinux.org/paru.git || error_exit "Failed to clone paru repository"
    cd paru
    makepkg -si --noconfirm || error_exit "Failed to build and install paru"

    cd "$HOME"
    rm -rf "$temp_dir"
    log "INFO" "Paru installed successfully"
}

install_aur_packages() {
    log "INFO" "Installing AUR packages..."

    local aur_packages=(
        thorium-browser-avx2-bin
        fnm
        uv
        kanata
        getnf
        tokyonight-gtk-theme-git
        bemoji
        appimagelauncher
        sesh-bin
    )

    paru -S --needed --noconfirm "${aur_packages[@]}" || error_exit "Failed to install AUR packages"
    log "INFO" "AUR packages installed successfully"
}

setup_devtool() {
    log "INFO" "Setting up Node.js..."

    if command -v fnm &>/dev/null; then
        fnm install --lts || log "WARN" "Failed to install Node.js LTS"

        log "INFO" "Node.js setup completed"
    else
        log "WARN" "fnm not found, skipping Node.js setup"
    fi

    log "INFO" "Setting up Rust..."

    if command -v rustup &>/dev/null; then
        rustup default statble || log "WARN" "Failed to install rust stable version"

        log "INFO" "Rust setup completed"
    else
        log "WARN" "rutstup not found, skipping rust setup"
    fi
}

setup_kanata() {
    log "INFO" "Setting up kanata..."

    # Create uinput group (ignore if exists)
    sudo groupadd uinput 2>/dev/null || true

    # Add user to groups
    sudo usermod -aG input,uinput "$USER"

    # Create udev rules
    sudo tee /etc/udev/rules.d/99-uinput.rules >/dev/null <<'EOF'
KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
EOF

    # Reload udev rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger

    # Load uinput module
    sudo modprobe uinput

    # Add to modules-load for persistent loading
    echo 'uinput' | sudo tee /etc/modules-load.d/uinput.conf >/dev/null

    # Enable kanata service
    systemctl --user daemon-reload
    if systemctl --user list-unit-files | grep -q kanata.service; then
        systemctl --user enable kanata.service
        log "INFO" "Kanata service enabled"
    else
        log "WARN" "Kanata service file not found, you may need to create it manually"
    fi

    log "INFO" "Kanata setup completed"
}

setup_docker() {
    log "INFO" "Setting up docker"

    if command -v docker &>/dev/null; then
        sudo systemctl enable docker.service
        sudo systemctl start docker.service

        newgrp docker
        sudo usermod -aG docker "$USER"

        log "INFO" "Docker setup completed"
    else
        log "WARN" "docker not found, skipping Node.js setup"
    fi
}

setup_zsh() {
    if [[ "$SHELL" != "/bin/zsh" ]] && [[ "$SHELL" != "/usr/bin/zsh" ]]; then
        sudo chsh -s /bin/zsh "$USER"
        log "INFO" "Default shell changed to zsh"
    fi

    ln -sf "$HOME/dotfiles/.zshenv" "$HOME/.zshenv"
    mkdir -p "$HOME/.local/share/zsh"
    touch "$HOME/.local/share/zsh/history"

    if [[ -z "${ZSH_VERSION:-}" ]]; then
        zsh
    fi
}

create_directories() {
    log "INFO" "Creating necessary directories..."

    local dirs=(
        "$HOME/.config"
        "$HOME/.local/bin"
        "$HOME/.local/share"
        "$HOME/.local/share/zsh"
        "$FONT_DIR"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
    done
}

setup_dotfile() {
    log "INFO" "Setting up dotfiles..."

    if [[ ! -d "$HOME/Pictures/walle" ]]; then
        git clone https://github.com/T2Knock/walle.git "$HOME/Pictures/walle"
        log "INFO" "Wallpapers cloned"
    fi

    if [[ ! -d "$HOME/dotfiles" ]]; then
        git clone https://github.com/T2Knock/dotfiles.git "$HOME/dotfiles"
        log "INFO" "Dotfiles cloned"

        cd "$HOME/dotfiles"
        stow -vt ~/.config .config
        log "INFO" "Dotfiles linked"

        # Update bat binary cache
        bat cache --build

        # Clone tmux tpm
        git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm && ~/.config/tmux/plugins/tpm/bin/install_plugins

        setup_kanata
        setup_devtool
        setup_zsh

        loginctl enable-linger "$USER"
    else
        log "INFO" "Dotfiles already exist, skipping clone and setup"
        log "WARN" "If you want to re-setup, remove ~/dotfiles directory first"
    fi
}

main() {
    if [[ "${1:-}" == "--confirm" ]]; then
        log "INFO" "Running with --confirm flag"
    else
        if [[ -t 0 ]]; then
            read -p "This will install and configure your Arch setup. Continue? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log "INFO" "Installation cancelled"
                exit 0
            fi
        fi
    fi

    log "INFO" "Starting Arch Linux post-installation script..."

    check_not_root
    create_directories

    install_fonts
    update_system
    install_official_packages
    install_paru
    install_aur_packages

    setup_dotfile

    log "INFO" "Post-installation script completed!"
    log "INFO" "You may need to reboot for all changes to take effect"
}

main "$@"
