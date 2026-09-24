#!/usr/bin/env bash

set -euo pipefail

show_help() {
    cat <<'EOF'
Usage: $(basename "$0") [OPTIONS]

Find files larger than a given size.

Options:
  -s SIZE   Size threshold (e.g., 100M, 1G). Default: 100M
  -d DIR    Directory to search. Default: current directory
  -h        Show this help message
EOF
}

SIZE="100M"
DIR="."
while getopts "s:d:h" opt; do
    case $opt in
        s) SIZE="$OPTARG" ;;
        d) DIR="$OPTARG" ;;
        h) show_help; exit 0 ;;
        *) show_help; exit 1 ;;
    esac
done

if ! command -v find >/dev/null 2>&1; then
    echo "Error: 'find' command not found." >&2
    exit 1
fi

echo "Searching for files larger than $SIZE in $DIR ..."
find "$DIR" -type f -size +"$SIZE" -exec du -h {} + 2>/dev/null | sort -hr
