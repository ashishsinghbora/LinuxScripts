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
for arg in "$@"; do
  case "$arg" in
    -h|--help) show_help ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

echo "Kernel version:" && uname -r

echo -e "\nLoaded modules:"
if command -v lsmod >/dev/null 2>&1; then
  lsmod
elif [[ -r /proc/modules ]]; then
  echo "(showing first 20 modules from /proc/modules)"
  (head -n 20 /proc/modules 2>/dev/null || true)
else
  echo "Kernel module information not available."
fi

if [[ -r /proc/config.gz ]]; then
  echo -e "\nKernel config (compressed, preview):"
  (zcat /proc/config.gz 2>/dev/null || true) | head -n 20 || true
else
  echo -e "\nKernel config not available (no /proc/config.gz)."
fi
