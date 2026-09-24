#!/usr/bin/env bash

set -euo pipefail

show_help() {
    cat <<'EOF'
Usage: $(basename "$0") [OPTIONS]

Display information about running processes.

Options:
  -a          Show all processes (default uses ps -e)
  -u USER     Filter by user
  -h          Show this help message
EOF
}

ALL=false
USER_FILTER=""
while getopts "au:h" opt; do
    case $opt in
        a) ALL=true ;;
        u) USER_FILTER="$OPTARG" ;;
        h) show_help; exit 0 ;;
        *) show_help; exit 1 ;;
    esac
done

if ! command -v ps >/dev/null 2>&1; then
    echo "Error: 'ps' command not found." >&2
    exit 1
fi

if $ALL; then
    CMD="ps -ef"
else
    CMD="ps -e"
fi

if [[ -n "$USER_FILTER" ]]; then
    CMD="$CMD -u $USER_FILTER"
fi

echo "Process list:"
$CMD
