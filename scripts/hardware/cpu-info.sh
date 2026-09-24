#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options]

Options:
  -h          Show this help message and exit

Displays CPU information using lscpu (if available) and /proc/cpuinfo.
The script is read‑only and safe to run on any Linux system.
EOF
  exit 0
}

while getopts "h" opt; do
  case "$opt" in
    h) show_help ;;
    *) show_help ;;
  esac
done

echo "=== lscpu output (if available) ==="
if command -v lscpu >/dev/null 2>&1; then
  lscpu
else
  echo "lscpu not found."
fi

echo -e "\n=== /proc/cpuinfo (first 20 lines) ==="
if [[ -r /proc/cpuinfo ]]; then
  head -n 20 /proc/cpuinfo
else
  echo "/proc/cpuinfo not readable."
fi
