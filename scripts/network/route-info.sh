#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options]

Options:
  -h, --help   Show this help message and exit

Displays the current routing table using ip route (or netstat -r as fallback).
EOF
  exit 0
}

# Parse arguments
while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    *) echo "Unknown option: $1"; show_help;;
  esac
  shift
done

if command -v ip >/dev/null 2>&1; then
  ip route show
elif command -v netstat >/dev/null 2>&1; then
  netstat -r
else
  echo "Neither ip nor netstat commands are available to display routing information."
  exit 1
fi
