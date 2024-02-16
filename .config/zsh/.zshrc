source $ZDOTDIR/zshrc

# fnm
export PATH="/home/ngochuynh/.local/share/fnm:$PATH"
eval "`fnm env`"

# bun completions
[ -s "/home/ngochuynh/.bun/_bun" ] && source "/home/ngochuynh/.bun/_bun"
