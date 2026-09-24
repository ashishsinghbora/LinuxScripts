#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: gpu-info.sh [options]

Options:
  -h, --help    Show this help message and exit

Description:
  Detects and displays basic information about GPUs present on the system.
  It uses 'lspci' to list PCI devices and optionally 'glxinfo' for OpenGL details.
EOF
  exit 0
}

# Parse options
while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    *) echo "Unknown option: $1" >&2; exit 1;;
  esac
  shift
done

# Check required commands
if ! command -v lspci >/dev/null 2>&1; then
  echo "Error: 'lspci' command not found. Install pciutils." >&2
  exit 1
fi

# Find GPU entries
GPU_DEVS=$(lspci -nn | grep -i "vga\|3d\|display" || true)
if [[ -z "$GPU_DEVS" ]]; then
  echo "No GPU devices detected."
  exit 0
fi

echo "Detected GPU(s):"
printf "%s\n" "$GPU_DEVS"

# Optional OpenGL info
if command -v glxinfo >/dev/null 2>&1; then
  echo "\nOpenGL renderer information (via glxinfo):"
  glxinfo | grep -i "renderer" | head -n 5 || true
else
  echo "\nTip: Install 'mesa-utils' to get OpenGL details via glxinfo."
fi
