#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options] [host]

Options:
  -h, --help   Show this help message and exit
  -c <count>   Number of ping packets to send (default: 4)

Performs a simple ICMP ping test to the specified host (default 8.8.8.8).
The script reports success/failure and average round‑trip time.
EOF
  exit 0
}

# Default values
count=4
host="8.8.8.8"

# Parse arguments
while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    -c)
      count="$2"
      shift 2
      ;;
    *)
      host="$1"
      shift
      ;;
  esac
done

if ! command -v ping >/dev/null 2>&1; then
  echo "ping command not found. Install iputils-ping or equivalent."
  exit 1
fi

echo "Pinging $host with $count packet(s)..."
if ping -c "$count" "$host"; then
  echo "Ping succeeded."
else
  echo "Ping failed."
  exit 1
fi
