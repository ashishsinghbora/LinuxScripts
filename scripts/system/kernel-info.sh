#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options]

Options:
  -h, --help   Show this help message and exit

Displays kernel information including version, loaded modules, and configuration (if available).
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

echo "Kernel version:" && uname -r

echo -e "\nLoaded modules:" && lsmod

if [[ -r /proc/config.gz ]]; then
  echo -e "\nKernel config (compressed):"
  zcat /proc/config.gz | head -n 20
else
  echo -e "\nKernel config not available (no /proc/config.gz)."
fi
