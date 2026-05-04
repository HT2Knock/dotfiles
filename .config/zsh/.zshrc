#!/usr/bin/zsh
# zmodload zsh/zprof

# =============================================================================
# ZINIT PLUGIN MANAGER
# =============================================================================

if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" &&
        print -P "%F{33} %F{34}Installation successful.%f%b" ||
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
((${+_comps})) && _comps[zinit]=_zinit

zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# =============================================================================
# COMPLETION SYSTEM
# =============================================================================

autoload -Uz compinit
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
compinit -C

# =============================================================================
# PLUGINS
# =============================================================================

# Configure eza BEFORE loading (required)
zstyle ':omz:plugins:eza' 'dirs-first' yes
zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' 'header' yes
zstyle ':omz:plugins:eza' 'icons' yes

# Load snippets with Turbo Mode
zinit wait'0' lucid for \
    OMZP::git \
    OMZP::aws \
    OMZP::ssh-agent \
    OMZP::eza \
    OMZP::gcloud

# Load plugins with Turbo Mode
zinit wait'0' lucid for \
    zsh-users/zsh-autosuggestions \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-completions \
    Aloxaf/fzf-tab \
    atuinsh/atuin

# =============================================================================
# SHELL OPTIONS
# =============================================================================

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY
setopt AUTO_CD
setopt GLOB_COMPLETE
setopt MENU_COMPLETE

# =============================================================================
# SHELL ENVS
# =============================================================================

# Ensure cache directory exists
mkdir -p "$XDG_CACHE_HOME/zsh"

source "$ZDOTDIR/zsh-functions"
zsh_add_file "zsh-exports"
zsh_add_file "zsh-aliases"

# =============================================================================
# TOOL INITIALIZATIONS
# =============================================================================

eval "$(fnm env --use-on-cd)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd j)"
eval "$(fzf --zsh)"
eval "$(uv generate-shell-completion zsh)"

# =============================================================================
# KEY BINDINGS
# =============================================================================

# Function to be called after zsh-vi-mode is initialized
function zvm_after_init() {
    bindkey -s "^o" "y^J"
    bindkey -s "^v" "f^J"
    bindkey "^y" autosuggest-accept
}

zinit wait'0' lucid for \
    jeffreytse/zsh-vi-mode

zinit wait'0' lucid atload"zinit cdreplay -q" blockf for \
    zsh-users/zsh-completions

# zprof
