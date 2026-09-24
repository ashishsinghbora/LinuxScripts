#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options]

Options:
  -h, --help   Show this help message and exit

Scans all attached block devices for SMART health status using smartctl.
If smartctl is not installed, the script will inform the user.
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

if ! command -v smartctl >/dev/null 2>&1; then
  echo "smartctl not found. Please install smartmontools to use this script."
  exit 1
fi

# Identify block devices (exclude partitions)
devices=$(lsblk -dn -o NAME,TYPE | awk '$2=="disk" {print "/dev/"$1}')
if [[ -z "$devices" ]]; then
  echo "No block devices found."
  exit 0
fi

for dev in $devices; do
  echo "=== $dev ==="
  # Run health check; ignore non-SMART capable devices
  if smartctl -i "$dev" | grep -q "SMART support is: Available"; then
    smartctl -H "$dev" || true
  else
    echo "SMART not supported on $dev"
  fi
  echo
done
