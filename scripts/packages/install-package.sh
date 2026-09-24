#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options] <package_name>

Options:
  -h          Show this help message and exit
  -y          Automatically answer yes to any prompts (use with caution)

Installs the specified package using the detected package manager.
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
  INSTALL_CMD="pacman -S --noconfirm"
elif command -v apt >/dev/null 2>&1; then
  PM="apt"
  INSTALL_CMD="apt install -y"
elif command -v dnf >/dev/null 2>&1; then
  PM="dnf"
  INSTALL_CMD="dnf install -y"
elif command -v zypper >/dev/null 2>&1; then
  PM="zypper"
  INSTALL_CMD="zypper install -y"
else
  echo "Unsupported package manager."
  exit 1
fi

echo "Detected package manager: $PM"

if $AUTOYES; then
  sudo "$INSTALL_CMD" "$PACKAGE"
else
  read -r -p "Proceed to install '$PACKAGE' using $PM? [y/N] " resp
  case "$resp" in
    y|Y|yes|YES) sudo "$INSTALL_CMD" "$PACKAGE" ;;
    *) echo "Installation aborted."; exit 0 ;;
  esac
fi
