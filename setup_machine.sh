#!/bin/bash

# This script automates the setup of a new machine, installing
# dotfiles, development tools, fonts, and icons.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Helper Functions ---

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# --- Section 1: Dotfiles Management with Stow ---
# Stow is used to manage dotfiles by creating symbolic links from a central
# repository (your dotfiles directory) to their appropriate locations in the
# home directory. This keeps your configurations version-controlled and tidy.

install_stow() {
  echo "Checking for stow..."
  if ! command_exists stow; then
    echo "stow not found. Installing stow..."
    sudo apt-get update
    sudo apt-get install -y stow
    echo "stow installed successfully."
  else
    echo "stow is already installed."
  fi
}

deploy_dotfiles() {
  echo "Deploying dotfiles using stow..."
  # Navigate to the dotfiles directory where your config folders are located
  # Assuming this script is run from /mnt/work/dotfiles
  cd /mnt/work/dotfiles/.config || {
    echo "Error: Could not navigate to .config directory."
    exit 1
  }

  # List of dotfile directories to stow. Add more as needed.
  # These correspond to the directories inside your .config folder.
  DOTFILES=(
    alacritty
    atuin
    bat
    dunst
    ghostty
    i3
    i3status-rust
    kanata
    lazydocker
    lazygit
    neofetch
    nvim
    picom
    polybar
    ranger
    rofi
    systemd
    tmux
    zathura
    zsh
  )

  for dir in "${DOTFILES[@]}"; do
    if [ -d "$dir" ]; then
      echo "Stowing $dir..."
      # -t specifies the target directory (your home directory)
      # -S specifies the source directory (the current directory, which is .config)
      stow --target="$HOME/.config" "$dir"
    else
      echo "Warning: Directory $dir not found in .config. Skipping."
    fi
  done
  echo "Dotfiles deployment complete."
}

# --- Section 2: Rust and Cargo Tools ---
# This section will handle the installation of Rust and then use Cargo to install
# specific tools like lazygit and lazydocker.

install_rust_and_cargo() {
  echo "Checking for Rust and Cargo..."
  if ! command_exists cargo; then
    echo "Rust/Cargo not found. Installing rustup..."
    # Install rustup, which manages Rust toolchains
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # Source cargo's environment to make it available in the current shell
    source "$HOME/.cargo/env"
    echo "Rust and Cargo installed successfully."
  else
    echo "Rust and Cargo are already installed."
  fi

  echo "Installing Cargo-based tools..."
  CARGO_TOOLS=(
    bat
    bottom
    dua-cli
    exa
    eza
    fd-find
    git-delta
    i3status-rs
    kanata
    ripgrep
    skim
    tree-sitter-cli
    xh
    yazi-cli
    yazi-fm
    zoxide
    starship
  )

  for tool in "${CARGO_TOOLS[@]}"; do
    if ! command_exists "$tool"; then
      echo "Installing $tool..."
      cargo install "$tool"
    else
      echo "$tool is already installed."
    fi
  done
  echo "Cargo tools installation complete."
}

install_go() {
  echo "Checking for Go..."
  if ! command_exists go; then
    echo "Go not found. Installing Go..."
    sudo apt-get update
    sudo apt-get install -y golang
    echo "Go installed successfully."
  else
    echo "Go is already installed."
  fi
}

install_go_tools() {
  echo "Installing Go-based tools (lazygit, lazydocker)..."
  # Ensure Go binaries are in PATH for this session
  export PATH="$PATH:$(go env GOPATH)/bin"

  TOOLS=(
    github.com/jesseduffield/lazygit@latest
    github.com/jesseduffield/lazydocker@latest
  )

  for tool in "${TOOLS[@]}"; do
    TOOL_NAME=$(basename "$tool" | cut -d'@' -f1)
    if ! command_exists "$TOOL_NAME"; then
      echo "Installing $TOOL_NAME..."
      go install "$tool"
    else
      echo "$TOOL_NAME is already installed."
    fi
  done
  echo "Go tools installation complete."
}

install_gum() {
  echo "Checking for gum..."
  if ! command_exists gum; then
    echo "gum not found. Installing gum..."
    go install github.com/charmbracelet/gum@latest
    echo "gum installed successfully."
  else
    echo "gum is already installed."
  fi
}

install_pnpm() {
  echo "Checking for pnpm..."
  if ! command_exists pnpm; then
    echo "pnpm not found. Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    echo "pnpm installed successfully."
  else
    echo "pnpm is already installed."
  fi
}

install_atuin() {
  echo "Checking for atuin..."
  if ! command_exists atuin; then
    echo "atuin not found. Installing atuin..."
    curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | bash
    echo "atuin installed successfully."
  else
    echo "atuin is already installed."
  fi
}

# --- Section 3: Zsh and Command-Line Tools ---
# This section installs Zsh, its plugin manager (Zinit), and various
# command-line utilities used in your Zsh configuration.

install_zsh_and_dependencies() {
  echo "Checking for Zsh and its dependencies..."

  # Install Zsh
  if ! command_exists zsh; then
    echo "Zsh not found. Installing zsh..."
    sudo apt-get update
    sudo apt-get install -y zsh
    echo "Zsh installed successfully. Please set Zsh as your default shell after this script finishes: chsh -s $(which zsh)"
  else
    echo "Zsh is already installed."
  fi

  # Install Zinit (Zsh Plugin Manager)
  if [[ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
    echo "Zinit not found. Installing Zinit..."
    mkdir -p "$HOME/.local/share/zinit" && chmod g-rwX "$HOME/.local/share/zinit"
    git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
    echo "Zinit installed successfully."
  else
    echo "Zinit is already installed."
  fi

  # Install fzf
  if ! command_exists fzf; then
    echo "fzf not found. Installing fzf..."
    sudo apt-get update
    sudo apt-get install -y fzf
    # Run fzf install script for shell integration
    # This is usually interactive, so we'll try to run it non-interactively if possible
    # Or provide instructions for manual run
    echo "Running fzf install script for shell integration. You might need to press 'y' or 'n'."
    # Attempt non-interactive install, or provide manual instruction
    # The fzf install script can be tricky to automate fully non-interactively
    # For now, we'll just install the package and rely on the user to run `~/.fzf/install` if needed.
    # A better approach would be to clone fzf and run its install script with --all --no-bash --no-fish
    echo "fzf installed. If shell integration is missing, run ~/.fzf/install manually."
  else
    echo "fzf is already installed."
  fi

  # Install other command-line tools identified from .zshrc and aliases
  echo "Installing other command-line tools..."
  TOOLS=(
    xclip # Clipboard utility
  )

  for tool in "${TOOLS[@]}"; do
    if ! command_exists "$tool"; then
      echo "Installing $tool..."
      sudo apt-get install -y "$tool" || echo "Warning: Could not install $tool via apt. Please install manually if needed."
    else
      echo "$tool is already installed."
    fi
  done
  echo "Command-line tools installation complete."
}

# --- Section 4: i3 and Desktop Environment Dependencies ---
# This section installs tools and utilities required by your i3 window manager
# and other desktop environment components.

install_i3_and_desktop_dependencies() {
  echo "Installing i3 and desktop environment dependencies..."
  TOOLS=(
    brightnessctl # Screen brightness control
    playerctl     # Media player control
    maim          # Screenshot utility
    dunst         # Notification daemon
    xbanish       # Hides mouse cursor when not in use
    greenclip     # Clipboard manager
    picom         # Compositor
    fcitx         # Input method editor (base package)
    # Add specific fcitx components if needed, e.g., fcitx-mozc, fcitx-frontend-gtk3
  )

  for tool in "${TOOLS[@]}"; do
    if ! command_exists "$tool"; then
      echo "Installing $tool..."
      sudo apt-get install -y "$tool" || echo "Warning: Could not install $tool via apt. Please install manually if needed."
    else
      echo "$tool is already installed."
    fi
  done
  echo "i3 and desktop environment dependencies installation complete."
}

# --- Main Execution ---
echo "Starting new machine setup script..."

install_stow
deploy_dotfiles

install_rust_and_cargo
install_go
install_go_tools

install_gum
install_pnpm
install_atuin

install_zsh_and_dependencies
install_i3_and_desktop_dependencies

install_fonts_and_icons

echo "New machine setup script finished."
