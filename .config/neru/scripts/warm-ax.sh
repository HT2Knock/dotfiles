#!/usr/bin/env bash
set -euo pipefail

# Build warm-ax.swift once into the cache, then run it.
# Usage: warm-ax.sh <bundle-id>

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SOURCE="$SCRIPT_DIR/warm-ax.swift"
readonly BINARY="$HOME/Library/Caches/neru/warm-ax"

if [[ ! -x "$BINARY" || "$SOURCE" -nt "$BINARY" ]]; then
    mkdir -p "$(dirname "$BINARY")"
    swiftc -O "$SOURCE" -o "$BINARY"
fi

exec "$BINARY" "$@"
