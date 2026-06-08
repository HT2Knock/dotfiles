#!/usr/bin/zsh

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

# =============================================================================
# COMPLETION SYSTEM
# =============================================================================

autoload -Uz compinit
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
compinit

# =============================================================================
# PLUGINS
# =============================================================================

# Configure eza BEFORE loading (required)
zstyle ':omz:plugins:eza' 'dirs-first' yes
zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' 'header' yes
zstyle ':omz:plugins:eza' 'icons' yes


zstyle :omz:plugins:ssh-agent identities id_ed25519 id_ed25519_second

# OMZ snippets
zinit for \
    OMZP::git \
    OMZP::aws \
    OMZP::ssh-agent \
    OMZP::eza \
    OMZP::gcloud

# Core interactive plugins (load eagerly for reliability)
zinit for \
    zsh-users/zsh-autosuggestions \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-completions \
    Aloxaf/fzf-tab \
    atuinsh/atuin \
    jeffreytse/zsh-vi-mode

# =============================================================================
# SHELL OPTIONS
# =============================================================================

setopt HIST_IGNORE_ALL_DUPS
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
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

eval "$(/opt/homebrew/bin/brew shellenv)"
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
