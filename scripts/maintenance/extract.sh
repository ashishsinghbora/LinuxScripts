#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: extract.sh [options] <archive_file> [destination]

Options:
  -h, --help    Show this help message and exit
  -l, --list    List archive contents without extracting

Description:
  Safely extracts common archive types (.tar, .tar.gz, .tgz, .tar.bz2,
  .tbz2, .tar.xz, .txz, .zip, .7z, .rar) to the destination directory
  (defaults to current directory).
  Performs security checks to prevent directory traversal attacks (../)
  and absolute path overwrites.
EOF
  exit 0
}

LIST_ONLY=false
ARCHIVE=""
DEST=""

while (( "$#" )); do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -l|--list)
      LIST_ONLY=true
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      exit 1
      ;;
    *)
      if [[ -z "$ARCHIVE" ]]; then
        ARCHIVE="$1"
      elif [[ -z "$DEST" ]]; then
        DEST="$1"
      else
        echo "Error: Unexpected additional argument: $1" >&2
        exit 1
      fi
      ;;
  esac
  shift
done

if [[ -z "$ARCHIVE" ]]; then
  echo "Error: Archive file required." >&2
  echo "Run '$0 --help' for usage." >&2
  exit 1
fi

if [[ ! -f "$ARCHIVE" ]]; then
  echo "Error: Archive file '$ARCHIVE' does not exist." >&2
  exit 1
fi

DEST="${DEST:-.}"

if [[ ! -d "$DEST" ]]; then
  echo "Error: Destination '$DEST' is not a directory." >&2
  exit 1
fi

# Detect format
FORMAT=""
case "$ARCHIVE" in
  *.tar.gz|*.tgz)   FORMAT="tar.gz" ;;
  *.tar.bz2|*.tbz2) FORMAT="tar.bz2" ;;
  *.tar.xz|*.txz)   FORMAT="tar.xz" ;;
  *.tar)            FORMAT="tar" ;;
  *.zip)            FORMAT="zip" ;;
  *.rar)            FORMAT="rar" ;;
  *.7z)             FORMAT="7z" ;;
  *)
    echo "Error: Unsupported archive format: $ARCHIVE" >&2
    exit 1
    ;;
esac

# Validate required tool
check_tool() {
  local tool="$1"
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Error: Required utility '$tool' is not installed." >&2
    exit 1
  fi
}

case "$FORMAT" in
  tar*) check_tool tar ;;
  zip)      check_tool unzip ;;
  rar)      check_tool unrar ;;
  7z)       
    if command -v 7z >/dev/null 2>&1; then
      SEVEN_Z="7z"
    elif command -v 7za >/dev/null 2>&1; then
      SEVEN_Z="7za"
    else
      echo "Error: Required utility '7z' or '7za' is not installed." >&2
      exit 1
    fi
    ;;
esac

# Security check: verify no entries contain absolute paths or ../ traversal
validate_entries() {
  local entry
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    if [[ "$entry" =~ ^/ ]] || [[ "$entry" =~ ^[a-zA-Z]: ]]; then
      echo "Security Error: Archive contains absolute path entry: $entry" >&2
      return 1
    fi
    if [[ "$entry" =~ (^|/)\.\.(/|$) ]]; then
      echo "Security Error: Archive contains path traversal entry: $entry" >&2
      return 1
    fi
  done
  return 0
}

# List or check contents
list_entries() {
  case "$FORMAT" in
    tar*)
      tar -tf "$ARCHIVE"
      ;;
    zip)
      unzip -Z -1 "$ARCHIVE"
      ;;
    rar)
      unrar lb "$ARCHIVE"
      ;;
    7z)
      "$SEVEN_Z" l -ba -slt "$ARCHIVE" | grep '^Path = ' | sed 's/^Path = //'
      ;;
  esac
}

if $LIST_ONLY; then
  list_entries
  exit 0
fi

# Run traversal inspection
if ! list_entries | validate_entries; then
  echo "Error: Extraction aborted due to security violations in archive." >&2
  exit 1
fi

# Extract
case "$FORMAT" in
  tar.gz)   tar -xzf "$ARCHIVE" -C "$DEST" ;;
  tar.bz2)  tar -xjf "$ARCHIVE" -C "$DEST" ;;
  tar.xz)   tar -xJf "$ARCHIVE" -C "$DEST" ;;
  tar)      tar -xf "$ARCHIVE" -C "$DEST" ;;
  zip)      unzip -q -o -d "$DEST" "$ARCHIVE" ;;
  rar)      unrar x -o+ "$ARCHIVE" "$DEST/" ;;
  7z)       "$SEVEN_Z" x -y -o"$DEST" "$ARCHIVE" ;;
esac

echo "Extraction of '$ARCHIVE' into '$DEST' completed successfully."
