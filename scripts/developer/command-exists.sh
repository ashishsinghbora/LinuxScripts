#!/usr/bin/env bash

set -euo pipefail

show_help() {
    cat <<'EOF'
Usage: $(basename "$0") COMMAND

Check whether a command exists in PATH.

Options:
  -h    Show this help message
EOF
}

if [[ "${1-}" == "-h" ]]; then
    show_help
    exit 0
fi

if [[ $# -ne 1 ]]; then
    echo "Error: Exactly one command name required." >&2
    show_help
    exit 1
fi

CMD="$1"
if command -v "$CMD" >/dev/null 2>&1; then
    echo "Command '$CMD' is available at $(command -v "$CMD")"
    exit 0
else
    echo "Command '$CMD' is NOT found in PATH"
    exit 1
fi
