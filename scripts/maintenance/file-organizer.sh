#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: file-organizer.sh [options] [directory]

Options:
  -h, --help      Show this help message and exit
  -n, --dry-run   Show what would be moved without moving any files
  -d, --dir DIR   Target directory to organize (default: current directory)

Description:
  Safely organizes unorganized loose files in a directory into subfolders
  based on their file extensions (Images, Documents, Archives, Audio, Video, Code).
  - Skips directories, symlinks, hidden files (starting with .), and files without extensions.
  - Safely handles filenames with spaces, special characters, and Unicode.
  - Safe dry-run mode enabled via -n / --dry-run.
  - Prevents accidental execution directly on root '/' or home directory.
EOF
  exit 0
}

TARGET_DIR="."
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
      TARGET_DIR="$1"
      ;;
  esac
  shift
done

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: Directory '$TARGET_DIR' does not exist." >&2
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd -P)"

# Prevent accidental execution on / or $HOME directly
if [[ "$TARGET_DIR" == "/" ]]; then
  echo "Error: Refusing to organize root directory '/'." >&2
  exit 1
fi

if [[ -n "${HOME:-}" && "$TARGET_DIR" == "$HOME" ]]; then
  echo "Error: Refusing to organize user home directory root '$HOME' directly." >&2
  echo "Please specify a subfolder (e.g. ~/Downloads or ~/Desktop)." >&2
  exit 1
fi

echo "=== File Organizer ==="
echo "Target directory: $TARGET_DIR"
if $DRY_RUN; then
  echo "Mode: DRY RUN (no files will be moved)"
fi
echo ""

get_category() {
  local ext="${1,,}"
  case "$ext" in
    jpg|jpeg|png|gif|bmp|svg|webp|tiff|ico) echo "Images" ;;
    pdf|doc|docx|txt|rtf|odt|xls|xlsx|ppt|pptx|csv|md) echo "Documents" ;;
    zip|tar|gz|bz2|xz|7z|rar|tgz|tbz2|txz) echo "Archives" ;;
    mp3|wav|ogg|flac|aac|m4a|wma) echo "Audio" ;;
    mp4|mkv|avi|mov|wmv|flv|webm|m4v) echo "Video" ;;
    py|js|ts|c|cpp|h|hpp|go|rs|java|html|css|json|yaml|yml|sh|bash) echo "Code" ;;
    *) echo "" ;;
  esac
}

moved_count=0
skipped_count=0

# Iterate over regular files in TARGET_DIR (non-recursive, skip symlinks and hidden files)
while IFS= read -r -d '' file; do
  # Skip symlinks to avoid broken relative links or dangling targets
  [[ -L "$file" ]] && continue

  filename="$(basename "$file")"
  # Skip hidden files
  [[ "$filename" == .* ]] && continue

  # Extract extension
  ext="${filename##*.}"
  if [[ "$ext" == "$filename" ]]; then
    # No extension
    continue
  fi

  category="$(get_category "$ext")"
  if [[ -n "$category" ]]; then
    dest_dir="$TARGET_DIR/$category"
    dest_file="$dest_dir/$filename"

    if $DRY_RUN; then
      echo "[DRY RUN] Would move '$filename' -> '$category/'"
      moved_count=$((moved_count + 1))
    else
      mkdir -p "$dest_dir"
      if [[ -e "$dest_file" ]]; then
        echo "Skipping '$filename': already exists in '$category/'"
        skipped_count=$((skipped_count + 1))
      else
        mv -- "$file" "$dest_file"
        echo "Moved '$filename' -> '$category/'"
        moved_count=$((moved_count + 1))
      fi
    fi
  fi
done < <(find "$TARGET_DIR" -maxdepth 1 -type f -print0)

echo ""
if $DRY_RUN; then
  echo "Dry run completed. Files that would be moved: $moved_count"
else
  echo "Organization complete. Files moved: $moved_count, skipped: $skipped_count"
fi
