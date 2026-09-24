#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: memory-info.sh [options]

Options:
  -h, --help    Show this help message and exit

Description:
  Displays total and free memory information.
  Uses 'free -h' for a human‑readable summary and
  prints the first few lines of /proc/meminfo for details.
EOF
  exit 0
}

# Parse arguments
while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    *) echo "Unknown option: $1" >&2; exit 1;;
  esac
  shift
done

# Ensure required commands are present
if ! command -v free >/dev/null 2>&1; then
  echo "Error: 'free' command not found. Install procps." >&2
  exit 1
fi

echo "Memory usage (human readable):"
free -h

echo "\nDetailed memory info from /proc/meminfo (first 20 lines):"
head -n 20 /proc/meminfo
