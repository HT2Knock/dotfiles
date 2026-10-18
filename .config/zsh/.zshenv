# Load private keys. Keep that file plain KEY=value lines, without `export`:
# systemd reads the same file through EnvironmentFile (see
# .config/systemd/user/opencode.service) and cannot parse shell syntax.
if [[ -r "$HOME/.secrets/opencode-env.zsh" ]]; then
  set -a
  source "$HOME/.secrets/opencode-env.zsh"
  set +a
fi
