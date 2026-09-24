#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: directory-size.sh [options] [directory]

Options:
  -h, --help     Show this help message and exit
  -d, --dir DIR  Directory to measure (default: current directory)

Description:
  Displays the total human-readable disk space used by a directory.
  If omitted, measures the current working directory.
EOF
  exit 0
}

TARGET_DIR=""

while (( "$#" )); do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -d|--dir)
      if [[ -n "${2-}" && "${2-}" != -* ]]; then
        TARGET_DIR="$2"
        shift
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      exit 1
      ;;
    *)
      if [[ -z "$TARGET_DIR" ]]; then
        TARGET_DIR="$1"
      else
        echo "Error: Unexpected additional argument: $1" >&2
        exit 1
      fi
      ;;
  esac
  shift
done

TARGET_DIR="${TARGET_DIR:-.}"

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: '$TARGET_DIR' is not a directory." >&2
  exit 1
fi

if ! command -v du >/dev/null 2>&1; then
  echo "Error: 'du' utility is required but not installed." >&2
  exit 1
fi

REAL_PATH="$(cd "$TARGET_DIR" && pwd -P)"
SIZE="$(du -sh "$REAL_PATH" 2>/dev/null | cut -f1)"

echo "Directory: $REAL_PATH"
echo "Size:      $SIZE"
