#!/usr/bin/env bash

set -euo pipefail

show_help() {
    cat <<'EOF'
Usage: $(basename "$0") [OPTIONS] ARCHIVE [DEST]

Extract common archive types to a destination directory.
If DEST is omitted, extracts to the current directory.

Options:
  -h    Show this help message
EOF
}

if [[ "${1-}" == "-h" ]]; then
    show_help
    exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Error: Invalid number of arguments." >&2
    show_help
    exit 1
fi

ARCHIVE="$1"
DEST="${2:-.}"

if [[ ! -f "$ARCHIVE" ]]; then
    echo "Error: Archive file '$ARCHIVE' does not exist." >&2
    exit 1
fi

if [[ ! -d "$DEST" ]]; then
    echo "Error: Destination '$DEST' is not a directory." >&2
    exit 1
fi

# Determine archive type based on extension
case "$ARCHIVE" in
    *.tar.gz|*.tgz)   tar -xzf "$ARCHIVE" -C "$DEST" ;;
    *.tar.bz2|*.tbz2) tar -xjf "$ARCHIVE" -C "$DEST" ;;
    *.tar.xz|*.txz)   tar -xJf "$ARCHIVE" -C "$DEST" ;;
    *.zip)            unzip -d "$DEST" "$ARCHIVE" ;;
    *.rar)            unrar x "$ARCHIVE" "$DEST" ;;
    *.7z)             7z x "$ARCHIVE" -o"$DEST" ;;
    *)
        echo "Error: Unsupported archive format: $ARCHIVE" >&2
        exit 1
        ;;
esac

echo "Extraction of '$ARCHIVE' completed."
