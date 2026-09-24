#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: pci-devices.sh [options]

Options:
  -h, --help    Show this help message and exit

Description:
  Lists PCI devices present on the system using 'lspci'.
EOF
  exit 0
}

while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    *) echo "Unknown option: $1" >&2; exit 1;;
  esac
  shift
done

if ! command -v lspci >/dev/null 2>&1; then
  echo "Error: 'lspci' command not found. Please install pciutils." >&2
  exit 1
fi

echo "=== PCI Devices ==="
lspci
