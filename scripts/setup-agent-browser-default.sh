#!/usr/bin/env bash
set -euo pipefail

# Register the agent Chrome as this machine's default browser.
# Run once after stow, or again after the repository moves.

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly APPLICATIONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
readonly ENTRY="$APPLICATIONS_DIR/browse-agent.desktop"

mkdir -p "$APPLICATIONS_DIR"

cat >"$ENTRY" <<EOF
[Desktop Entry]
Type=Application
Name=Agent Chrome
Comment=Isolated Chrome on display :99 for agents
Exec=$REPO_DIR/scripts/agent-browser-open.sh %U
Terminal=false
NoDisplay=true
Categories=Network;WebBrowser;
MimeType=text/html;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=false
EOF

xdg-mime default browse-agent.desktop \
    x-scheme-handler/http \
    x-scheme-handler/https \
    text/html
env -u BROWSER xdg-settings set default-web-browser browse-agent.desktop ||
    printf 'xdg-settings skipped; the MIME handlers above still route links.\n' >&2
update-desktop-database "$APPLICATIONS_DIR" 2>/dev/null || true

printf 'Default browser: %s\n' "$(env -u BROWSER xdg-settings get default-web-browser)"
