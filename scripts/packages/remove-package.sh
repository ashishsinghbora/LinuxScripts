#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options] <package_name>

Options:
  -h          Show this help message and exit
  -y          Automatically answer yes to any prompts (use with caution)

Removes the specified package using the detected package manager.
The script will prompt for confirmation unless -y is provided.
EOF
  exit 0
}

# Default values
AUTOYES=false

# Parse options
while getopts "hy" opt; do
  case "$opt" in
    h) show_help ;;
    y) AUTOYES=true ;;
    *) show_help ;;
  esac
done

shift $((OPTIND -1))

if [[ $# -lt 1 ]]; then
  echo "Error: package name required."
  show_help
fi

PACKAGE="$1"

# Detect package manager
if command -v pacman >/dev/null 2>&1; then
  PM="pacman"
  REMOVE_CMD="pacman -R --noconfirm"
elif command -v apt >/dev/null 2>&1; then
  PM="apt"
  REMOVE_CMD="apt remove -y"
elif command -v dnf >/dev/null 2>&1; then
  PM="dnf"
  REMOVE_CMD="dnf remove -y"
elif command -v zypper >/dev/null 2>&1; then
  PM="zypper"
  REMOVE_CMD="zypper remove -y"
else
  echo "Unsupported package manager."
  exit 1
fi

echo "Detected package manager: $PM"

if $AUTOYES; then
  sudo $REMOVE_CMD "$PACKAGE"
else
  read -p "Proceed to remove '$PACKAGE' using $PM? [y/N] " resp
  case "$resp" in
    y|Y|yes|YES) sudo $REMOVE_CMD "$PACKAGE" ;;
    *) echo "Removal aborted."; exit 0 ;;
  esac
fi
