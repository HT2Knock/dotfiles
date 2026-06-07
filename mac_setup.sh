#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="$HOME/mac-install.log"
readonly FONT_DIR="$HOME/Library/Fonts"

readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log() {
	local level="$1"
	shift
	local message="$*"
	local timestamp
	timestamp=$(date '+%Y-%m-%d %H:%M:%S')

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

check_xcode_cli() {
	log "INFO" "Checking Xcode Command Line Tools..."

	if ! xcode-select -p &>/dev/null; then
		log "WARN" "Xcode Command Line Tools not found"
		log "INFO" "Please run: xcode-select --install"
		log "INFO" "Then re-run this script after installation completes"
		exit 1
	else
		log "INFO" "Xcode Command Line Tools found"
	fi
}

check_homebrew() {
	log "INFO" "Checking Homebrew..."

	if command -v brew &>/dev/null; then
		log "INFO" "Homebrew already installed"
		return 0
	fi

	log "INFO" "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error_exit "Failed to install Homebrew"

	# Ensure brew is in PATH for Apple Silicon Macs
	if [[ -x "/opt/homebrew/bin/brew" ]]; then
		eval "$(/opt/homebrew/bin/brew shellenv)"
	fi

	log "INFO" "Homebrew installed successfully"
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

	log "INFO" "Fonts installed to $FONT_DIR"
}

install_packages() {
	log "INFO" "Installing Homebrew formulae..."

	local formulae=(
		# Base development tools
		go gcc rustup-init awscli

		# Editor and multiplexer
		neovim tmux herdr opencode

		# File management
		yazi fd ripgrep stow

		# Modern CLI tools
		starship eza duf dust git-delta dua-cli zoxide bat atuin bottom tlrc

		# Git and Docker tools
		lazygit lazydocker gh

		# Media and utilities
		ffmpeg imagemagick jq p7zip

		# Fuzzy finder
		fzf

		# Development version managers
		fnm uv sesh

		# System tools
		fastfetch orbstack
	)

	brew install "${formulae[@]}" || error_exit "Failed to install Homebrew formulae"
	log "INFO" "Homebrew formulae installed successfully"

	log "INFO" "Installing Homebrew casks..."

	local casks=(
		bitwarden
		firefox
		ghostty
		raycast
		zed
		dbeaver-community
		signal
		microsoft-teams
		claude-code
	)

	brew install --cask "${casks[@]}" || log "WARN" "Failed to install some casks"
	log "INFO" "Homebrew casks installed successfully"
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

setup_tmux() {
	log "INFO" "Setting up tmux plugin manager..."

	local tpm_dir="$HOME/.config/tmux/plugins/tpm"

	if [[ -d "$tpm_dir" ]]; then
		log "INFO" "TPM already installed"
	else
		if git clone https://github.com/tmux-plugins/tpm "$tpm_dir"; then
			log "INFO" "TPM cloned successfully"
			log "INFO" "Open tmux and press <prefix> + I to install plugins"
		else
			log "WARN" "Failed to clone tmux plugin manager"
		fi
	fi
}

setup_zsh() {
	log "INFO" "Setting up zsh..."

	ln -sf "$HOME/dotfiles/.zshenv" "$HOME/.zshenv"
	mkdir -p "$HOME/.local/share/zsh"
	touch "$HOME/.local/share/zsh/history"

	log "INFO" "Zsh setup completed"
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
		log "ERROR" "Dotfiles repository not found at ~/dotfiles"
		log "INFO" "Please clone your dotfiles repository to ~/dotfiles first"
		exit 1
	fi

	cd "$HOME/dotfiles" || error_exit "Failed to change to dotfiles directory"

	if ! command -v stow &>/dev/null; then
		log "WARN" "stow not found, installing via Homebrew..."
		brew install stow || error_exit "Failed to install stow"
		log "INFO" "stow installed successfully"
	fi

	stow -vt ~/.config .config
	log "INFO" "Dotfiles linked"

	# Update bat binary cache
	if command -v bat &>/dev/null; then
		bat cache --build || log "WARN" "Failed to rebuild bat cache"
	fi

	setup_devtool
	setup_tmux
	setup_zsh

	log "INFO" "Dotfiles setup completed"
}

print_manual_steps() {
	echo ""
	log "INFO" "========================================"
	log "INFO" "Manual steps remaining:"
	log "INFO" "========================================"
	log "INFO" "1. Install Thorium Browser:"
	log "INFO" "   https://github.com/Alex313031/Thorium-MacOS/releases"
	log "INFO" "   Download .dmg for your architecture and drag to /Applications/"
	log "INFO" ""
	log "INFO" "2. Open Docker Desktop to complete setup"
	log "INFO" ""
	log "INFO" "3. Open Ghostty and verify it works"
	log "INFO" ""
	log "INFO" "4. Open tmux and press <prefix> + I to install plugins"
	log "INFO" ""
	log "INFO" "5. Run: nvim --headless +'checkhealth' +qa"
	log "INFO" "========================================"
}

main() {
	if [[ "${1:-}" == "--confirm" ]]; then
		log "INFO" "Running with --confirm flag"
	else
		if [[ -t 0 ]]; then
			read -p "This will install and configure your macOS setup. Continue? (y/N): " -n 1 -r
			echo
			if [[ ! $REPLY =~ ^[Yy]$ ]]; then
				log "INFO" "Installation cancelled"
				exit 0
			fi
		fi
	fi

	log "INFO" "Starting macOS setup script..."

	check_xcode_cli
	check_homebrew
	create_directories

	install_fonts
	install_packages

	setup_dotfile

	print_manual_steps

	log "INFO" "macOS setup script completed!"
}

main "$@"
