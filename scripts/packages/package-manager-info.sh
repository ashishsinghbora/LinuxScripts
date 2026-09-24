#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options]

Options:
  -h          Show this help message and exit

Detects the system's package manager (pacman, apt, dnf, zypper) and prints
basic information about it (name, version, and a brief description).
EOF
  exit 0
}

while getopts "h" opt; do
  case "$opt" in
    h) show_help ;;
    *) show_help ;;
  esac
done

if command -v pacman >/dev/null 2>&1; then
  echo "Package manager: pacman (Arch Linux)"
  pacman --version | head -n1
elif command -v apt >/dev/null 2>&1; then
  echo "Package manager: apt (Debian/Ubuntu)"
  apt --version | head -n1
elif command -v dnf >/dev/null 2>&1; then
  echo "Package manager: dnf (Fedora/RHEL)"
  dnf --version | head -n1
elif command -v zypper >/dev/null 2>&1; then
  echo "Package manager: zypper (openSUSE)"
  zypper --version | head -n1
else
  echo "No supported package manager detected."
  exit 1
fi
