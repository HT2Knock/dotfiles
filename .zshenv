# OpenSSH sends TERM only in the pty request, and Tailscale SSH starts the
# login shell through login(1), which sets TERM=dumb. Use a real terminal
# type. Keep an explicitly dumb TERM in non-interactive shells.
case ${TERM-} in
  ""|unknown)
    export TERM=xterm-256color
    ;;
  dumb)
    if [[ -o interactive ]]; then
      export TERM=xterm-256color
    fi
    ;;
esac

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
