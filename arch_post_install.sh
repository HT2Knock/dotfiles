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

check_dependencies() {
	log "INFO" "Checking dependencies..."

	local missing=()
	local required_commands=("git" "pacman")

	for cmd in "${required_commands[@]}"; do
		if ! command -v "$cmd" &>/dev/null; then
			missing+=("$cmd")
		fi
	done

	if [[ ${#missing[@]} -gt 0 ]]; then
		error_exit "Missing required commands: ${missing[*]}"
	fi

	log "INFO" "All dependencies satisfied"
}

install_fonts() {
	log "INFO" "Installing fonts..."

	if [[ ! -d "$SCRIPT_DIR/fonts" ]]; then
		log "WARN" "Fonts directory not found, skipping font installation"
		return 0
	fi

	mkdir -p "$FONT_DIR"
	cp -r "$SCRIPT_DIR/fonts/"* "$FONT_DIR/" 2>/dev/null || {
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
		qt5-wayland qt6-wayland kvantum qt5ct qt6ct

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

	cleanup_temp() {
		cd "$HOME" 2>/dev/null || true
		rm -rf "$temp_dir" 2>/dev/null || true
	}

	trap cleanup_temp EXIT

	mkdir -p "$temp_dir"
	cd "$temp_dir" || error_exit "Failed to change to temp directory"

	git clone https://aur.archlinux.org/paru.git || error_exit "Failed to clone paru repository"
	cd paru || error_exit "Failed to change to paru directory"
	makepkg -si --noconfirm || error_exit "Failed to build and install paru"

	cd "$HOME" || error_exit "Failed to return to home directory"
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
		rustup default stable || log "WARN" "Failed to install rust stable version"

		log "INFO" "Rust setup completed"
	else
		log "WARN" "rustup not found, skipping rust setup"
	fi
}

setup_kanata() {
	log "INFO" "Setting up kanata..."

	if ! getent group uinput &>/dev/null; then
		sudo groupadd uinput || log "WARN" "Failed to create uinput group"
	else
		log "INFO" "uinput group already exists"
	fi

	local user_groups=$(groups "$USER")
	if ! echo "$user_groups" | grep -q input; then
		sudo usermod -aG input "$USER" || log "WARN" "Failed to add user to input group"
	else
		log "INFO" "User already in input group"
	fi

	if ! echo "$user_groups" | grep -q uinput; then
		sudo usermod -aG uinput "$USER" || log "WARN" "Failed to add user to uinput group"
	else
		log "INFO" "User already in uinput group"
	fi

	if [[ ! -f /etc/udev/rules.d/99-uinput.rules ]]; then
		sudo tee /etc/udev/rules.d/99-uinput.rules >/dev/null <<'EOF'
KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
EOF
		sudo udevadm control --reload-rules || log "WARN" "Failed to reload udev rules"
		sudo udevadm trigger || log "WARN" "Failed to trigger udev rules"
		log "INFO" "Udev rules created"
	else
		log "INFO" "Udev rules already exist"
	fi

	if ! lsmod | grep -q uinput; then
		sudo modprobe uinput || log "WARN" "Failed to load uinput module"
		log "INFO" "Uinput module loaded"
	else
		log "INFO" "Uinput module already loaded"
	fi

	if [[ ! -f /etc/modules-load.d/uinput.conf ]]; then
		echo 'uinput' | sudo tee /etc/modules-load.d/uinput.conf >/dev/null || log "WARN" "Failed to create uinput module config"
		log "INFO" "Uinput module persistence configured"
	else
		log "INFO" "Uinput module persistence already configured"
	fi

	systemctl --user daemon-reload || log "WARN" "Failed to reload systemd user daemon"
	if systemctl --user list-unit-files 2>/dev/null | grep -q kanata.service; then
		if ! systemctl --user is-enabled kanata.service &>/dev/null; then
			systemctl --user enable kanata.service || log "WARN" "Failed to enable kanata service"
			log "INFO" "Kanata service enabled"
		else
			log "INFO" "Kanata service already enabled"
		fi
	else
		log "WARN" "Kanata service file not found, you may need to create it manually"
	fi

	log "INFO" "Kanata setup completed (you may need to log out and back in for group changes to take effect)"
}

setup_docker() {
	log "INFO" "Setting up docker"

	if command -v docker &>/dev/null; then
		if ! sudo systemctl is-enabled docker.service &>/dev/null; then
			sudo systemctl enable docker.service || log "WARN" "Failed to enable docker service"
		fi

		if ! sudo systemctl is-active docker.service &>/dev/null; then
			sudo systemctl start docker.service || log "WARN" "Failed to start docker service"
		fi

		if ! groups "$USER" | grep -q docker; then
			sudo usermod -aG docker "$USER" || log "WARN" "Failed to add user to docker group"
		else
			log "INFO" "User already in docker group"
		fi

		log "INFO" "Docker setup completed (you may need to log out and back in for group changes to take effect)"
	else
		log "WARN" "docker not found, skipping Docker setup"
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
		git clone https://github.com/T2Knock/walle.git "$HOME/Pictures/walle" || log "WARN" "Failed to clone wallpapers"
		log "INFO" "Wallpapers cloned"
	fi

	if [[ ! -d "$HOME/dotfiles" ]]; then
		git clone https://github.com/T2Knock/dotfiles.git "$HOME/dotfiles" || error_exit "Failed to clone dotfiles repository"
		log "INFO" "Dotfiles cloned"

		cd "$HOME/dotfiles" || error_exit "Failed to change to dotfiles directory"

		if ! command -v stow &>/dev/null; then
			log "WARN" "stow not found, installing via pacman..."
			sudo pacman -S --needed --noconfirm stow || error_exit "Failed to install stow"
			log "INFO" "stow installed successfully"
		fi

		stow -vt ~/.config .config
		log "INFO" "Dotfiles linked"

		# Update bat binary cache
		bat cache --build

		# Clone tmux tpm
		if git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm; then
			~/.config/tmux/plugins/tpm/bin/install_plugins || log "WARN" "Failed to install tmux plugins"
		else
			log "WARN" "Failed to clone tmux plugin manager"
		fi

		setup_kanata
		setup_devtool
		setup_zsh

		loginctl enable-linger "$USER" || log "WARN" "Failed to enable linger for user"
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
	check_dependencies
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
