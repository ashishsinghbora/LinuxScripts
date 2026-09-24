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
  - Skips directories, hidden files (starting with .), and scripts.
  - Safely handles filenames with spaces.
  - Safe dry-run mode enabled via -n / --dry-run.
EOF
  exit 0
}

TARGET_DIR="."
DRY_RUN=false

while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    -n|--dry-run) DRY_RUN=true;;
    -d|--dir)
      shift
      TARGET_DIR="${1:-.}"
      ;;
    -*) echo "Unknown option: $1" >&2; exit 1;;
    *) TARGET_DIR="$1";;
  esac
  shift
done

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: Directory '$TARGET_DIR' does not exist." >&2
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
echo "=== File Organizer ==="
echo "Target directory: $TARGET_DIR"
if $DRY_RUN; then
  echo "Mode: DRY RUN (no files will be moved)"
fi
echo ""

get_category() {
  local ext="${1,,}"
  case "$ext" in
    jpg|jpeg|png|gif|bmp|svg|webp|tiff) echo "Images" ;;
    pdf|doc|docx|txt|rtf|odt|xls|xlsx|ppt|pptx|csv) echo "Documents" ;;
    zip|tar|gz|bz2|xz|7z|rar) echo "Archives" ;;
    mp3|wav|ogg|flac|aac|m4a) echo "Audio" ;;
    mp4|mkv|avi|mov|wmv|flv|webm) echo "Video" ;;
    py|js|ts|c|cpp|h|hpp|go|rs|java|html|css|json|yaml|yml|sh) echo "Code" ;;
    *) echo "" ;;
  esac
}

moved_count=0

# Iterate over regular files in TARGET_DIR (non-recursive, ignore hidden files)
while IFS= read -r -d '' file; do
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
    else
      mkdir -p "$dest_dir"
      if [[ -e "$dest_file" ]]; then
        echo "Skipping '$filename': already exists in '$category/'"
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
  echo "Dry run completed."
else
  echo "Organization complete. Files moved: $moved_count"
fi
