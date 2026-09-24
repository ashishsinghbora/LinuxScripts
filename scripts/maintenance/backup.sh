#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: backup.sh [options]

Options:
  -d, --dir DIR       Directory to back up (default: current directory)
  -o, --output DIR    Output directory for backup archive (default: ./backups)
  -n, --dry-run       Display planned actions without creating archive
  -h, --help          Show this help message and exit

Description:
  Creates a timestamped compressed backup (.tar.gz) of the specified
  directory. Prevents recursive inclusion if the output directory is
  inside the source directory, cleans up incomplete archives on failure,
  and handles spaces and Unicode characters safely.
EOF
  exit 0
}

SRC_DIR="."
OUT_DIR="./backups"
DRY_RUN=false

while (( "$#" )); do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -n|--dry-run)
      DRY_RUN=true
      ;;
    -d|--dir)
      if [[ -n "${2-}" && "${2-}" != -* ]]; then
        SRC_DIR="$2"
        shift
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -o|--output)
      if [[ -n "${2-}" && "${2-}" != -* ]]; then
        OUT_DIR="$2"
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
      echo "Error: Unexpected positional argument: $1" >&2
      exit 1
      ;;
  esac
  shift
done

if ! command -v tar >/dev/null 2>&1; then
  echo "Error: 'tar' utility is required but not installed." >&2
  exit 1
fi

if [[ ! -e "$SRC_DIR" ]]; then
  echo "Error: Source path '$SRC_DIR' does not exist." >&2
  exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Error: Source path '$SRC_DIR' is not a directory." >&2
  exit 1
fi

SRC_DIR="$(realpath "$SRC_DIR")"

if [[ "$SRC_DIR" == "/" ]]; then
  echo "Error: Refusing to create full root '/' backup without targeted configuration." >&2
  exit 1
fi

# Resolve output directory
if $DRY_RUN; then
  # Don't create directory in dry-run mode
  OUT_DIR="$(realpath -m "$OUT_DIR")"
else
  mkdir -p "$OUT_DIR"
  OUT_DIR="$(realpath "$OUT_DIR")"
fi

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BASE_NAME="$(basename "$SRC_DIR")"
PARENT_DIR="$(dirname "$SRC_DIR")"
BACKUP_FILE="$OUT_DIR/${BASE_NAME}_backup_${TIMESTAMP}.tar.gz"

# Build tar exclusion arguments if OUT_DIR is inside or equal to SRC_DIR
declare -a TAR_OPTS=()

if [[ "$OUT_DIR" == "$SRC_DIR" ]]; then
  TAR_OPTS+=(--exclude="${BASE_NAME}/*.tar.gz" --exclude="${BASE_NAME}/*.tar.bz2" --exclude="${BASE_NAME}/*.tar.xz")
elif [[ "$OUT_DIR" == "$SRC_DIR"/* ]]; then
  # Output directory is inside the source directory; compute relative path to exclude
  REL_OUT="${OUT_DIR#"$SRC_DIR"/}"
  TAR_OPTS+=(--exclude="${BASE_NAME}/${REL_OUT}" --exclude="${BASE_NAME}/*.tar.gz")
fi

if $DRY_RUN; then
  echo "[DRY RUN] Source directory: $SRC_DIR"
  echo "[DRY RUN] Output directory: $OUT_DIR"
  echo "[DRY RUN] Target archive:   $BACKUP_FILE"
  if [[ ${#TAR_OPTS[@]} -gt 0 ]]; then
    echo "[DRY RUN] Exclusions:       ${TAR_OPTS[*]}"
  fi
  echo "[DRY RUN] Command: tar -czf \"$BACKUP_FILE\" ${TAR_OPTS[*]} -C \"$PARENT_DIR\" \"$BASE_NAME\""
  exit 0
fi

# Setup cleanup on failure/interruption
cleanup_on_error() {
  local exit_code=$?
  if [[ $exit_code -ne 0 && -f "$BACKUP_FILE" ]]; then
    echo "Warning: Backup interrupted or failed. Removing partial archive: $BACKUP_FILE" >&2
    rm -f "$BACKUP_FILE"
  fi
  exit "$exit_code"
}
trap cleanup_on_error EXIT INT TERM

echo "Creating backup of '$SRC_DIR' at '$BACKUP_FILE' ..."

tar -czf "$BACKUP_FILE" "${TAR_OPTS[@]}" -C "$PARENT_DIR" "$BASE_NAME"

# Remove trap on success
trap - EXIT INT TERM

ARCHIVE_SIZE="$(du -h "$BACKUP_FILE" | cut -f1)"
echo "Backup completed successfully: $BACKUP_FILE (Size: $ARCHIVE_SIZE)"
