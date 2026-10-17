export EDITOR="nvim"
export TERMINAL="ghostty"
export BROWSER="helium-browser"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# User-scoped tools must be visible to non-interactive shells too, so that
# `ssh host 'tool'` and scripts find the same binaries as an interactive shell.
for dir in "$HOME/.opencode/bin" "$HOME/.local/bin"; do
    case ":$PATH:" in
        *":$dir:"*) ;;
        *) export PATH="$dir:$PATH" ;;
    esac
done
