source $ZDOTDIR/zshrc

# fnm
export PATH="/home/ngochuynh/.local/share/fnm:$PATH"
eval "`fnm env`"

# bun completions
[ -s "/home/cubable-be-4/.bun/_bun" ] && source "/home/cubable-be-4/.bun/_bun"
