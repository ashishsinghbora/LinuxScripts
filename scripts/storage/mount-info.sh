#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options]

Options:
  -h, --help   Show this help message and exit
  -t <type>    Show only mounts of the specified filesystem type (e.g., ext4, nfs)

Displays current mount points and their options. If a type is provided, filters the output.
EOF
  exit 0
}

# Default values
filter_type=""

# Parse arguments
while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    -t)
      filter_type="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      ;;
  esac
done

if ! command -v findmnt >/dev/null 2>&1; then
  echo "findmnt command not found. Falling back to /proc/mounts."
  if [[ -n "$filter_type" ]]; then
    awk -v type="$filter_type" '$3 == type {print $1, $2, $3, $4}' /proc/mounts
  else
    cat /proc/mounts
  fi
else
  if [[ -n "$filter_type" ]]; then
    findmnt -t "$filter_type" -o SOURCE,TARGET,FSTYPE,OPTIONS
  else
    findmnt -o SOURCE,TARGET,FSTYPE,OPTIONS
  fi
fi
