#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: disk-health.sh [options] [device]

Options:
  -h, --help   Show this help message and exit

Description:
  Inspects S.M.A.R.T. health status of disk block devices using smartctl.
  If [device] is specified (e.g. /dev/sda or /dev/nvme0n1), checks only
  that device. Otherwise scans attached physical disks.
  Note: Requires root/sudo privileges to query raw drive hardware.
EOF
  exit 0
}

TARGET_DEV=""

for arg in "$@"; do
  case "$arg" in
    -h|--help)
      show_help
      ;;
    -*)
      echo "Error: Unknown option: $arg" >&2
      exit 1
      ;;
    *)
      if [[ -z "$TARGET_DEV" ]]; then
        TARGET_DEV="$1"
      else
        echo "Error: Unexpected additional argument: $1" >&2
        exit 1
      fi
      ;;
  esac
done

if ! command -v smartctl >/dev/null 2>&1; then
  echo "smartctl not found. Please install smartmontools (e.g. pacman -S smartmontools, apt install smartmontools)." >&2
  exit 1
fi

SUDO_CMD=()
if [[ $EUID -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO_CMD=(sudo)
  else
    echo "Warning: Running as non-root without sudo. SMART queries may fail with permission denied." >&2
  fi
fi

declare -a DISKS=()

if [[ -n "$TARGET_DEV" ]]; then
  if [[ ! -b "$TARGET_DEV" ]]; then
    echo "Error: Device '$TARGET_DEV' is not a valid block device." >&2
    exit 1
  fi
  DISKS=("$TARGET_DEV")
else
  # Discover physical disks using lsblk if available, otherwise check /sys/block
  if command -v lsblk >/dev/null 2>&1; then
    while IFS= read -r dev; do
      [[ -n "$dev" ]] && DISKS+=("/dev/$dev")
    done < <(lsblk -dn -o NAME,TYPE 2>/dev/null | awk '$2=="disk" && $1 !~ /^(loop|zram|ram)/ {print $1}' || true)
  fi

  if [[ ${#DISKS[@]} -eq 0 && -d /sys/block ]]; then
    for node in /sys/block/*; do
      devname="$(basename "$node")"
      if [[ "$devname" =~ ^(sd[a-z]|nvme[0-9]+n[0-9]+|hd[a-z]|vd[a-z]) ]]; then
        DISKS+=("/dev/$devname")
      fi
    done
  fi
fi

if [[ ${#DISKS[@]} -eq 0 ]]; then
  echo "No physical block devices detected for SMART health checking."
  exit 0
fi

echo "=== S.M.A.R.T. Disk Health Check ==="
echo ""

for dev in "${DISKS[@]}"; do
  echo "--- Device: $dev ---"
  
  # Check if SMART is supported and enabled
  smart_info="$("${SUDO_CMD[@]}" smartctl -i "$dev" 2>&1 || true)"
  
  if echo "$smart_info" | grep -qi "SMART support is: Available"; then
    echo "SMART: Supported"
    
    # Query health status
    health_output="$("${SUDO_CMD[@]}" smartctl -H "$dev" 2>&1 || true)"
    if echo "$health_output" | grep -qiE "PASSED|OK"; then
      echo "Status: [HEALTHY] Self-Assessment Test Result: PASSED"
    elif echo "$health_output" | grep -qi "FAILED"; then
      echo "Status: [CRITICAL WARNING] Self-Assessment Test Result: FAILED!"
    else
      echo "Status: [UNKNOWN] Check detailed smartctl output."
    fi
  else
    echo "SMART: Not supported or unavailable on this device (e.g. virtualized, container, or USB enclosure)."
  fi
  echo ""
done
