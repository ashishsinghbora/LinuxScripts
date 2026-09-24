#!/usr/bin/env bash

set -euo pipefail

show_help() {
    cat <<'EOF'
Usage: $(basename "$0") [OPTIONS]

Create a timestamped backup of a directory using tar.gz.

Options:
  -d DIR   Directory to backup (default: current directory)
  -o DIR   Output directory for backup files (default: ./backups)
  -h       Show this help message
EOF
}

# Default values
SRC_DIR="."
OUT_DIR="./backups"

while getopts "d:o:h" opt; do
    case $opt in
        d) SRC_DIR="$OPTARG" ;;
        o) OUT_DIR="$OPTARG" ;;
        h) show_help; exit 0 ;;
        *) show_help; exit 1 ;;
    esac
done

if ! command -v tar >/dev/null 2>&1; then
    echo "Error: 'tar' command not found." >&2
    exit 1
fi

# Resolve absolute paths
SRC_DIR=$(realpath "$SRC_DIR")
OUT_DIR=$(realpath "$OUT_DIR")

mkdir -p "$OUT_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BASE_NAME=$(basename "$SRC_DIR")
BACKUP_FILE="$OUT_DIR/${BASE_NAME}_backup_${TIMESTAMP}.tar.gz"

echo "Creating backup of '$SRC_DIR' at '$BACKUP_FILE' ..."

tar -czf "$BACKUP_FILE" -C "$(dirname "$SRC_DIR")" "$(basename "$SRC_DIR")"

echo "Backup completed: $BACKUP_FILE"
