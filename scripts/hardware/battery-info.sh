#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: battery-info.sh [options]

Options:
  -h, --help    Show this help message and exit

Description:
  Displays battery status and power supply information.
  Uses 'upower' if available, otherwise queries /sys/class/power_supply/.
EOF
  exit 0
}

for arg in "$@"; do
  case "$arg" in
    -h|--help) show_help ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

echo "=== Battery & Power Information ==="
found=0

if command -v upower >/dev/null 2>&1; then
  devices=$(upower -e | grep -E 'battery|DisplayDevice' || true)
  if [[ -n "$devices" ]]; then
    while IFS= read -r dev; do
      [[ -z "$dev" ]] && continue
      echo "--- Device: $dev ---"
      upower -i "$dev" | grep -E "state|to\ full|percentage|capacity|technology|model|vendor" || true
      found=1
    done <<< "$devices"
  fi
fi

if [[ $found -eq 0 && -d /sys/class/power_supply ]]; then
  for ps in /sys/class/power_supply/*; do
    if [[ -d "$ps" ]]; then
      type=$(cat "$ps/type" 2>/dev/null || echo "Unknown")
      echo "--- Power Supply: $(basename "$ps") ($type) ---"
      [[ -f "$ps/status" ]] && echo "Status: $(cat "$ps/status")"
      [[ -f "$ps/capacity" ]] && echo "Capacity: $(cat "$ps/capacity")%"
      [[ -f "$ps/health" ]] && echo "Health: $(cat "$ps/health")"
      found=1
    fi
  done
fi

if [[ $found -eq 0 ]]; then
  echo "No battery or power supply devices detected (common in desktop or VM environments)."
fi
