#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: ssh-host-info.sh [options] [hostname|IP]

Options:
  -h, --help      Show this help message and exit
  -p, --port NUM  SSH port (default: 22)

Description:
  Retrieves SSH host key fingerprints and server banner for a target host.
  If no host is given, summarizes known hosts in ~/.ssh/known_hosts.
EOF
  exit 0
}

PORT=22
TARGET=""

while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    -p|--port)
      shift
      PORT="${1:-22}"
      ;;
    -*) echo "Unknown option: $1" >&2; exit 1;;
    *)
      if [[ -z "$TARGET" ]]; then
        TARGET="$1"
      else
        echo "Unexpected argument: $1" >&2
        exit 1
      fi
      ;;
  esac
  shift
done

echo "=== SSH Host Info ==="

if [[ -z "$TARGET" ]]; then
  KNOWN_HOSTS="$HOME/.ssh/known_hosts"
  if [[ -f "$KNOWN_HOSTS" ]]; then
    count=$(grep -c -v '^#' "$KNOWN_HOSTS" 2>/dev/null || echo 0)
    echo "Known hosts file: $KNOWN_HOSTS"
    echo "Total entries: $count"
    echo "Recent host entries:"
    tail -n 10 "$KNOWN_HOSTS" | awk '{print $1}'
  else
    echo "No ~/.ssh/known_hosts found."
  fi
  echo ""
  echo "Tip: Run '$0 <hostname>' to query remote host fingerprints."
  exit 0
fi

if ! command -v ssh-keyscan >/dev/null 2>&1; then
  echo "Error: 'ssh-keyscan' command not found. Install openssh-client." >&2
  exit 1
fi

echo "Querying host keys for $TARGET on port $PORT..."
keys=$(ssh-keyscan -p "$PORT" -T 5 "$TARGET" 2>/dev/null || true)

if [[ -z "$keys" ]]; then
  echo "Could not reach SSH service on $TARGET:$PORT."
  exit 1
fi

echo "Detected Host Keys:"
while IFS= read -r line; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue
  key_type=$(echo "$line" | awk '{print $2}')
  if command -v ssh-keygen >/dev/null 2>&1; then
    fp=$(echo "$line" | ssh-keygen -lf - 2>/dev/null || true)
    echo "  $key_type: $fp"
  else
    echo "  $key_type"
  fi
done <<< "$keys"
