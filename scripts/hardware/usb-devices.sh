#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: usb-devices.sh [options]

Options:
  -h, --help    Show this help message and exit

Description:
  Lists USB devices attached to the system using 'lsusb'.
  If 'lsusb' is not installed, it falls back to reading /sys/bus/usb/devices/.
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

echo "=== USB Devices ==="
if command -v lsusb >/dev/null 2>&1; then
  lsusb
elif [[ -d /sys/bus/usb/devices ]]; then
  found=0
  for dev in /sys/bus/usb/devices/*; do
    if [[ -f "$dev/product" ]]; then
      prod=$(cat "$dev/product" 2>/dev/null || true)
      manuf=$(cat "$dev/manufacturer" 2>/dev/null || true)
      echo "$(basename "$dev"): ${manuf:+[$manuf] }${prod}"
      found=1
    fi
  done
  if [[ $found -eq 0 ]]; then
    echo "No USB devices detected in /sys/bus/usb/devices."
  fi
else
  echo "Error: 'lsusb' not found and /sys/bus/usb/devices is unavailable." >&2
  exit 1
fi
