#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options]

Options:
  -h, --help   Show this help message and exit

Displays filesystem usage information, including size, type, and mount options.
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

echo "Filesystem size and type (human readable):"
if command -v df >/dev/null 2>&1; then
  df -Th
else
  echo "df command not found."
fi

echo -e "\nMount points and options:"
if command -v mount >/dev/null 2>&1; then
  mount | column -t
else
  echo "mount command not found."
fi

# Show extended info for ext* filesystems if tune2fs is available
if command -v tune2fs >/dev/null 2>&1; then
  echo -e "\nExtended ext* filesystem info:"
  while IFS= read -r line; do
    dev=$(echo "$line" | awk '{print $1}')
    fstype=$(echo "$line" | awk '{print $3}')
    if [[ "$fstype" == ext* ]]; then
      echo "--- $dev ($fstype) ---"
      tune2fs -l "$dev" | grep -E 'Filesystem state|Block count|Free blocks|Inode count|Free inodes'
    fi
  done < <(df -T | tail -n +2)
else
  echo -e "\nFor detailed ext* info, install e2fsprogs (tune2fs)."
fi
