source $ZDOTDIR/zshrc

# fnm
export PATH="/home/ngochuynh/.local/share/fnm:$PATH"
eval "`fnm env`"

# bun completions
[ -s "/home/cubable-be-4/.bun/_bun" ] && source "/home/cubable-be-4/.bun/_bun"

# pnpm
export PNPM_HOME="/home/cubable-be-4/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
