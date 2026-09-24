#!/usr/bin/env bash

set -euo pipefail

show_help() {
    cat <<'EOF'
Usage: $(basename "$0") [OPTIONS] HOST PORT

Check if a TCP port is open on a host.

Options:
  -h    Show this help message
EOF
}

if [[ "${1-}" == "-h" ]]; then
    show_help
    exit 0
fi

if [[ $# -ne 2 ]]; then
    echo "Error: HOST and PORT required" >&2
    show_help
    exit 1
fi

HOST="$1"
PORT="$2"

if ! command -v nc >/dev/null 2>&1; then
    echo "Error: 'nc' (netcat) not found. Install it to use this script." >&2
    exit 1
fi

# Try to connect with a timeout of 2 seconds.
if nc -z -w2 "$HOST" "$PORT" >/dev/null 2>&1; then
    echo "Port $PORT on $HOST is OPEN"
    exit 0
else
    echo "Port $PORT on $HOST is CLOSED or filtered"
    exit 1
fi
