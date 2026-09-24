#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options] -f <logfile>

Options:
  -f <logfile>   Path to the log file to inspect (required)
  -n <lines>     Number of tail lines to display (default: 20)
  -e <pattern>   Grep pattern to filter the log output (optional)
  -h, --help     Show this help message and exit

The script safely displays the last N lines of a log file, optionally filtering
by a grep pattern. It validates the file size to avoid overwhelming the terminal.
EOF
  exit 0
}

# Default values
lines=20
pattern=""
logfile=""

# Parse arguments
while (( "$#" )); do
  case "$1" in
    -f)
      logfile="$2"
      shift 2
      ;;
    -n)
      lines="$2"
      shift 2
      ;;
    -e)
      pattern="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      ;;
  esac
done

if [[ -z "$logfile" ]]; then
  echo "Error: log file must be specified with -f"
  show_help
fi

if [[ ! -f "$logfile" ]]; then
  echo "Error: file '$logfile' does not exist or is not a regular file"
  exit 1
fi

# Prevent reading extremely large files (e.g., >100M) without warning
max_size=$((100 * 1024 * 1024))
file_size=$(stat -c%s "$logfile")
if (( file_size > max_size )); then
  echo "Warning: log file is larger than 100M (${file_size} bytes). Displaying only the last $lines lines."
fi

if [[ -n "$pattern" ]]; then
  tail -n "$lines" "$logfile" | grep --color=auto -i "$pattern" || true
else
  tail -n "$lines" "$logfile"
fi
