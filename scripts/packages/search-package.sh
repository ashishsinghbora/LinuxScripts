#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: search-package.sh [options] <search_term>

Options:
  -h, --help    Show this help message and exit

Description:
  Searches the package repositories of the detected package manager
  (pacman, apt, dnf, zypper, apk) for the given term.
EOF
  exit 0
}

SEARCH_TERM=""

while (( "$#" )); do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      exit 1
      ;;
    *)
      if [[ -z "$SEARCH_TERM" ]]; then
        SEARCH_TERM="$1"
      else
        echo "Error: Unexpected additional argument: $1" >&2
        exit 1
      fi
      ;;
  esac
  shift
done

if [[ -z "$SEARCH_TERM" ]]; then
  echo "Error: search term required." >&2
  echo "Run '$0 --help' for usage." >&2
  exit 1
fi

if command -v pacman >/dev/null 2>&1; then
  echo "Searching with pacman for '$SEARCH_TERM'..."
  pacman -Ss "$SEARCH_TERM"
elif command -v apt-cache >/dev/null 2>&1; then
  echo "Searching with apt-cache for '$SEARCH_TERM'..."
  apt-cache search "$SEARCH_TERM"
elif command -v apt >/dev/null 2>&1; then
  echo "Searching with apt for '$SEARCH_TERM'..."
  apt search "$SEARCH_TERM"
elif command -v dnf >/dev/null 2>&1; then
  echo "Searching with dnf for '$SEARCH_TERM'..."
  dnf search "$SEARCH_TERM"
elif command -v zypper >/dev/null 2>&1; then
  echo "Searching with zypper for '$SEARCH_TERM'..."
  zypper search "$SEARCH_TERM"
elif command -v apk >/dev/null 2>&1; then
  echo "Searching with apk for '$SEARCH_TERM'..."
  apk search "$SEARCH_TERM"
else
  echo "Error: Unsupported or no package manager detected." >&2
  exit 1
fi
