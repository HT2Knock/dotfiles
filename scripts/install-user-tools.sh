#!/usr/bin/env bash
# Install the tools listed in packages/user-tools.txt without sudo.
# Run this on a new machine, or after editing the manifest.
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly MANIFEST="$REPO_DIR/packages/user-tools.txt"
readonly BIN_DIR="$HOME/.local/bin"

log() {
    local level="$1"
    shift
    printf '[%s] %s\n' "$level" "$*"
}

require() {
    local tool="$1"
    if ! command -v "$tool" >/dev/null 2>&1; then
        log error "missing dependency: $tool"
        return 1
    fi
}

install_webi() {
    local spec="$1"

    log info "webi: $spec"
    curl -fsSL "https://webi.sh/${spec}" | sh
}

select_asset() {
    local repo="$1"

    gh api "repos/${repo}/releases/latest" --jq '.assets[].browser_download_url' 2>/dev/null |
        grep -Ei 'linux' |
        grep -Ei 'x86_64|amd64' |
        grep -Eiv '\.(sha256|sha256sum|sig|asc|deb|rpm|apk)$' |
        grep -Ei '\.(tar\.gz|tgz|tar\.xz|zip)$' |
        head -n 1
}

install_github() {
    local repo="$1"
    local name="${repo##*/}"
    local url tmp base checksum

    url="$(select_asset "$repo")"
    if [[ -z "$url" ]]; then
        log error "no Linux x86_64 release asset for $repo"
        return 1
    fi

    log info "github: $repo -> $(basename "$url")"
    tmp="$(mktemp -d)"
    base="$(basename "$url")"
    curl -fsSL "$url" -o "$tmp/$base"

    if curl -fsSL "$url.sha256" -o "$tmp/$base.sha256" 2>/dev/null; then
        checksum="$tmp/$base.sha256"
        (cd "$tmp" && sha256sum -c "$(basename "$checksum")")
    else
        log warn "no checksum published for $base"
    fi

    case "$url" in
        *.tar.gz|*.tgz) tar -xzf "$tmp/$base" -C "$tmp" ;;
        *.tar.xz) tar -xJf "$tmp/$base" -C "$tmp" ;;
        *.zip) unzip -q "$tmp/$base" -d "$tmp" ;;
    esac

    mkdir -p "$BIN_DIR"
    find "$tmp" -maxdepth 3 -type f -name "$name" -exec install -m 755 {} "$BIN_DIR/$name" \;
    rm -rf "$tmp"

    if [[ -x "$BIN_DIR/$name" ]]; then
        log ok "$name installed at $BIN_DIR/$name"
    else
        log error "could not find $name in the release archive"
        return 1
    fi
}

install_official() {
    local name="$1"

    case "$name" in
        opencode)
            log info "official: opencode"
            curl -fsSL https://opencode.ai/v2/install | bash -s -- --no-modify-path
            ;;
        *)
            log error "no official installer for $name"
            return 1
            ;;
    esac
}

main() {
    local line prefix spec failures=0

    if [[ ! -f "$MANIFEST" ]]; then
        log error "manifest not found: $MANIFEST"
        return 1
    fi

    require gh || return 1
    require curl || return 1
    require tar || return 1
    require sha256sum || return 1

    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%#*}"
        line="${line//[[:space:]]/}"
        [[ -z "$line" ]] && continue

        prefix="${line%%:*}"
        spec="${line#*:}"

        case "$prefix" in
            webi) install_webi "$spec" || failures=$((failures + 1)) ;;
            github) install_github "$spec" || failures=$((failures + 1)) ;;
            official) install_official "$spec" || failures=$((failures + 1)) ;;
            *)
                log error "unknown source: $prefix"
                failures=$((failures + 1))
                ;;
        esac
    done < "$MANIFEST"

    if ((failures > 0)); then
        log error "$failures install(s) failed"
        return 1
    fi

    log ok "user tools installed"
}

main "$@"
