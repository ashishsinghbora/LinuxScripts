#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options]

Options:
  -h          Show this help message and exit

Displays a summary of hardware information by invoking the individual
hardware utility scripts (cpu, gpu, memory, usb, pci, battery).
The script simply aggregates their outputs; it does not modify the system.
EOF
  exit 0
}

while getopts "h" opt; do
  case "$opt" in
    h) show_help ;;
    *) show_help ;;
  esac
done

echo "=== CPU Information ==="
if [[ -x "$(dirname "$0")/../hardware/cpu-info.sh" ]]; then
  "$(dirname "$0")/../hardware/cpu-info.sh" || true
else
  echo "cpu-info.sh not found or not executable"
fi

echo -e "\n=== GPU Information ==="
if [[ -x "$(dirname "$0")/../hardware/gpu-info.sh" ]]; then
  "$(dirname "$0")/../hardware/gpu-info.sh" || true
else
  echo "gpu-info.sh not found or not executable"
fi

echo -e "\n=== Memory Information ==="
if [[ -x "$(dirname "$0")/../hardware/memory-info.sh" ]]; then
  "$(dirname "$0")/../hardware/memory-info.sh" || true
else
  echo "memory-info.sh not found or not executable"
fi

echo -e "\n=== USB Devices ==="
if [[ -x "$(dirname "$0")/../hardware/usb-devices.sh" ]]; then
  "$(dirname "$0")/../hardware/usb-devices.sh" || true
else
  echo "usb-devices.sh not found or not executable"
fi

echo -e "\n=== PCI Devices ==="
if [[ -x "$(dirname "$0")/../hardware/pci-devices.sh" ]]; then
  "$(dirname "$0")/../hardware/pci-devices.sh" || true
else
  echo "pci-devices.sh not found or not executable"
fi

echo -e "\n=== Battery Information ==="
if [[ -x "$(dirname "$0")/../hardware/battery-info.sh" ]]; then
  "$(dirname "$0")/../hardware/battery-info.sh" || true
else
  echo "battery-info.sh not found or not executable"
fi
