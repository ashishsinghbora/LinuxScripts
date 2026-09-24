#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options] <search_term>

Options:
  -h          Show this help message and exit

Searches the package repositories of the detected package manager for the given term.
The search is performed non‑interactively and does not modify the system.
EOF
  exit 0
}

# Parse options
while getopts "h" opt; do
  case "$opt" in
    h) show_help ;;
    *) show_help ;;
  esac
done

shift $((OPTIND-1))

if [[ $# -lt 1 ]]; then
  echo "Error: search term required."
  show_help
fi

TERM="$1"

if command -v pacman >/dev/null 2>&1; then
  echo "Searching with pacman for '$TERM'..."
  pacman -Ss "$TERM" | grep -v "^\s*#"
elif command -v apt-cache >/dev/null 2>&1; then
  echo "Searching with apt for '$TERM'..."
  apt-cache search "$TERM"
elif command -v dnf >/dev/null 2>&1; then
  echo "Searching with dnf for '$TERM'..."
  dnf search "$TERM"
elif command -v zypper >/dev/null 2>&1; then
  echo "Searching with zypper for '$TERM'..."
  zypper search "$TERM"
else
  echo "Unsupported package manager."
  exit 1
fi
