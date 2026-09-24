#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options]

Options:
  -h, --help   Show this help message and exit

Displays inode usage for all mounted filesystems and warns if any exceed 90% usage.
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

if ! command -v df >/dev/null 2>&1; then
  echo "df command not found. Cannot display inode usage."
  exit 1
fi

# Show inode usage
printf "\nInode usage (percentage used):\n"
df -iP | tail -n +2 | awk '{printf "%s %s %s %s %s %s\n", $1, $2, $3, $4, $5, $6}'

# Warn if any filesystem exceeds 90% inode usage
threshold=90
while read -r line; do
  usage=$(echo "$line" | awk '{print $5}' | tr -d "%")
  mount=$(echo "$line" | awk '{print $6}')
  if [[ $usage -ge $threshold ]]; then
    echo "Warning: $mount inode usage is ${usage}% (above ${threshold}%)"
  fi
done < <(df -iP | tail -n +2)
