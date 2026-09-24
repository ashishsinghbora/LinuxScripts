#!/usr/bin/env bash

set -euo pipefail

show_help() {
    cat <<'EOF'
Usage: $(basename "$0") [OPTIONS] [DIRECTORY]

Display the total size of a directory (including subdirectories).
If DIRECTORY is omitted, the current directory is used.

Options:
  -h    Show this help message
EOF
}

if [[ "${1-}" == "-h" ]]; then
    show_help
    exit 0
fi

DIR="${1:-.}"

if [[ ! -d "$DIR" ]]; then
    echo "Error: '$DIR' is not a directory" >&2
    exit 1
fi

# Use du to calculate size, suppress errors for inaccessible files.
size=$(du -sh "${DIR}" 2>/dev/null | cut -f1)

echo "Directory size of '$DIR': $size"
