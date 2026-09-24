#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options]

Options:
  -h, --help   Show this help message and exit

Lists systemd services that are in a failed state.
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

if command -v systemctl >/dev/null 2>&1; then
  echo "Failed services:" && systemctl --failed --no-legend || true
else
  echo "systemctl not available on this system."
fi
