#!/bin/bash

# New Machine Setup Script for Linux Mint
# Automates the setup of dotfiles, development tools, and desktop environment

set -euo pipefail

# --- Configuration ---
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="${DOTFILES_DIR:-${SCRIPT_DIR}}"
readonly CONFIG_DIR="${DOTFILES_DIR}/.config"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# --- Helper Functions ---

log() {
  local level="$1"
  shift
  case "$level" in
  INFO) echo -e "${GREEN}[INFO]${NC} $*" ;;
  WARN) echo -e "${YELLOW}[WARN]${NC} $*" ;;
  ERROR) echo -e "${RED}[ERROR]${NC} $*" ;;
  esac
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_package() {
  local package="$1"
  if command_exists "$package" || dpkg -l | grep -q "^ii.*$package "; then
    log INFO "$package already installed"
    return 0
  fi

  log INFO "Installing $package..."
  if sudo apt-get install -y "$package"; then
    log INFO "$package installed successfully"
  else
    log ERROR "Failed to install $package"
    return 1
  fi
}

# --- Update System ---
update_system() {
  log INFO "Updating package lists..."
  sudo apt-get update
}

# --- Dotfiles Management ---
install_stow() {
  log INFO "Installing stow for dotfiles management..."
  install_package stow
}

deploy_dotfiles() {
  log INFO "Deploying dotfiles using stow..."

  if [[ ! -d "$CONFIG_DIR" ]]; then
    log ERROR "Config directory not found: $CONFIG_DIR"
    log INFO "Please ensure your dotfiles repository has a .config directory"
    return 1
  fi

  local dotfiles=(
    alacritty atuin bat dunst ghostty i3 i3status-rust
    kanata lazydocker lazygit neofetch nvim picom
    polybar ranger rofi systemd tmux zathura zsh
  )

  cd "$CONFIG_DIR" || {
    log ERROR "Could not navigate to $CONFIG_DIR"
    return 1
  }

  for dir in "${dotfiles[@]}"; do
    if [[ -d "$dir" ]]; then
      log INFO "Stowing $dir..."
      stow --target="$HOME/.config" "$dir" 2>/dev/null || log WARN "Failed to stow $dir (may already exist)"
    else
      log WARN "Directory $dir not found. Skipping."
    fi
  done

  log INFO "Dotfiles deployment complete"
}

# --- Core System Packages ---
install_core_packages() {
  log INFO "Installing core system packages from README..."

  local core_packages=(
    # Development tools
    neovim
    tmux
    git
    curl
    build-essential

    # i3 and window manager
    i3
    i3lock-color # This might need PPA or manual install

    # Desktop environment tools
    dunst
    rofi
    picom
    feh
    lxappearance
    arandr
    pavucontrol
    maim
    nitrogen

    # Icons - Papirus
    papirus-icon-theme

    # Command line utilities
    xclip
    fzf
    zsh

    # Media and brightness controls
    brightnessctl
    playerctl

    # Other utilities
    fcitx
  )

  log INFO "Installing packages via apt..."
  for package in "${core_packages[@]}"; do
    install_package "$package" || log WARN "Could not install $package via apt"
  done
}

# --- Special Installations ---
install_special_packages() {
  log INFO "Installing packages that need special handling..."

  # i3lock-color might need PPA
  if ! command_exists i3lock-color; then
    log INFO "Installing i3lock-color..."
    if ! install_package i3lock-color; then
      log WARN "i3lock-color not available in default repos. You may need to install manually from:"
      log WARN "https://github.com/Raymo111/i3lock-color"
    fi
  fi

  # Check if i3status-rust is available or needs cargo install
  if ! command_exists i3status-rs && ! install_package i3status-rust; then
    log INFO "i3status-rust not available via apt, will be installed via cargo later"
  fi
}

# --- Rust and Cargo Tools ---
install_rust_and_cargo() {
  log INFO "Installing Rust and Cargo tools..."

  if ! command_exists cargo; then
    log INFO "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  else
    log INFO "Rust already installed"
  fi

  # Ensure cargo is in PATH
  export PATH="$HOME/.cargo/bin:$PATH"

  local cargo_tools=(
    bat
    bottom
    dua-cli
    exa
    eza
    fd-find
    git-delta
    i3status-rs # This was in your dotfiles list
    ripgrep
    starship
    tree-sitter-cli
    zoxide
  )

  for tool in "${cargo_tools[@]}"; do
    if [[ -f "$HOME/.cargo/bin/$tool" ]] || command_exists "$tool"; then
      log INFO "$tool already installed"
    else
      log INFO "Installing $tool via cargo..."
      cargo install "$tool" || log WARN "Failed to install $tool"
    fi
  done
}

# --- Go Tools ---
install_go_and_tools() {
  log INFO "Installing Go and Go-based tools..."

  install_package golang-go || install_package golang

  # Ensure Go binaries are in PATH
  export PATH="$PATH:$(go env GOPATH)/bin"

  local go_tools=(
    "github.com/jesseduffield/lazygit@latest"
    "github.com/jesseduffield/lazydocker@latest"
    "github.com/charmbracelet/gum@latest"
  )

  for tool_url in "${go_tools[@]}"; do
    local tool_name=$(basename "$tool_url" | cut -d'@' -f1)
    if command_exists "$tool_name"; then
      log INFO "$tool_name already installed"
    else
      log INFO "Installing $tool_name..."
      go install "$tool_url" || log WARN "Failed to install $tool_name"
    fi
  done
}

# --- Node.js Tools ---
install_node_tools() {
  log INFO "Installing Node.js tools..."

  if ! command_exists pnpm; then
    log INFO "Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
  else
    log INFO "pnpm already installed"
  fi
}

# --- Shell Tools ---
install_shell_tools() {
  log INFO "Installing shell enhancement tools..."

  # Install atuin
  if ! command_exists atuin; then
    log INFO "Installing atuin..."
    curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | bash
  else
    log INFO "atuin already installed"
  fi
}

# --- Zsh Setup ---
setup_zsh() {
  log INFO "Setting up Zsh..."

  # Zinit installation
  local zinit_dir="$HOME/.local/share/zinit"
  if [[ ! -f "$zinit_dir/zinit.git/zinit.zsh" ]]; then
    log INFO "Installing Zinit..."
    mkdir -p "$zinit_dir" && chmod g-rwX "$zinit_dir"
    git clone https://github.com/zdharma-continuum/zinit "$zinit_dir/zinit.git"
  else
    log INFO "Zinit already installed"
  fi

  # Suggest setting Zsh as default shell
  if [[ "$SHELL" != "$(which zsh)" ]]; then
    log INFO "To set Zsh as your default shell, run: chsh -s \$(which zsh)"
  fi
}

# --- Fonts ---
install_nerd_fonts() {
  log INFO "Installing JetBrains Mono Nerd Font..."

  local font_dir="$HOME/.local/share/fonts"
  mkdir -p "$font_dir"

  if [[ ! -f "$font_dir/JetBrainsMonoNerdFont-Regular.ttf" ]]; then
    log INFO "Downloading JetBrains Mono Nerd Font..."
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # Download JetBrains Mono Nerd Font
    curl -L "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" -o JetBrainsMono.zip
    unzip -q JetBrainsMono.zip -d JetBrainsMono

    # Copy font files
    find JetBrainsMono -name "*.ttf" -exec cp {} "$font_dir/" \;

    # Refresh font cache
    fc-cache -fv

    rm -rf "$temp_dir"
    log INFO "JetBrains Mono Nerd Font installed"
  else
    log INFO "JetBrains Mono Nerd Font already installed"
  fi
}

# --- Icons ---
install_papirus_icons() {
  log INFO "Installing Papirus icon theme..."

  # Papirus should be available via apt, but let's also check for PPA method
  if ! dpkg -l | grep -q papirus-icon-theme; then
    log INFO "Installing Papirus via PPA for latest version..."

    # Add Papirus PPA for latest version
    if ! grep -q "papirus/papirus" /etc/apt/sources.list.d/papirus*.list 2>/dev/null; then
      sudo add-apt-repository -y ppa:papirus/papirus
      sudo apt-get update
    fi

    # Install all Papirus variants
    local papirus_packages=(
      papirus-icon-theme
      papirus-folders
    )

    for package in "${papirus_packages[@]}"; do
      install_package "$package" || log WARN "Could not install $package"
    done

    log INFO "Papirus icon theme installed successfully"
  else
    log INFO "Papirus icon theme already installed"
  fi
}

# --- Update Shell Paths ---
update_paths() {
  log INFO "Updating shell paths..."

  local paths_to_add=(
    "$HOME/.cargo/bin"
    "$(go env GOPATH)/bin"
    "$HOME/.local/bin"
  )

  local shell_rc="$HOME/.zshrc"
  [[ -f "$shell_rc" ]] || shell_rc="$HOME/.bashrc"

  for path_dir in "${paths_to_add[@]}"; do
    if [[ -d "$path_dir" ]] && ! grep -q "$path_dir" "$shell_rc" 2>/dev/null; then
      echo "export PATH=\"$path_dir:\$PATH\"" >>"$shell_rc"
      log INFO "Added $path_dir to PATH in $shell_rc"
    fi
  done
}

# --- Main Function ---
main() {
  log INFO "Starting Linux Mint setup script..."
  log INFO "Dotfiles directory: $DOTFILES_DIR"

  # System updates and core setup
  update_system
  install_stow
  deploy_dotfiles

  # Install all packages
  install_core_packages
  install_special_packages

  # Development tools
  install_rust_and_cargo
  install_go_and_tools
  install_node_tools
  install_shell_tools

  # Shell, fonts, and icons
  setup_zsh
  install_nerd_fonts
  install_papirus_icons

  # Final setup
  update_paths

  log INFO "Setup completed successfully!"
  log INFO ""
  log INFO "Next steps:"
  log INFO "1. Restart your terminal or run: source ~/.zshrc"
  log INFO "2. Set Zsh as default shell: chsh -s \$(which zsh)"
  log INFO "3. Log out and back in to apply all changes"
  log INFO "4. Configure your desktop wallpaper with nitrogen"
  log INFO "5. Use lxappearance to set your theme and select Papirus icons"
  log INFO "6. Your JetBrains Mono Nerd Font is ready for terminal use"

  # Check for any missing packages that need manual installation
  if ! command_exists i3lock-color; then
    log WARN "i3lock-color may need manual installation from: https://github.com/Raymo111/i3lock-color"
  fi
}

# Run the script
main "$@"
