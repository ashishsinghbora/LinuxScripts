#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: package-manager-info.sh [options]

Options:
  -h, --help    Show this help message and exit

Description:
  Detects the system's package manager (pacman, apt, dnf, zypper, apk)
  and prints basic information about it (name and version).
EOF
  exit 0
}

for arg in "$@"; do
  case "$arg" in
    -h|--help)
      show_help
      ;;
    *)
      echo "Error: Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

if command -v pacman >/dev/null 2>&1; then
  echo "Package manager: pacman (Arch Linux)"
  pacman --version | head -n1
elif command -v apt >/dev/null 2>&1; then
  echo "Package manager: apt (Debian/Ubuntu)"
  apt --version | head -n1
elif command -v apt-get >/dev/null 2>&1; then
  echo "Package manager: apt-get (Debian/Ubuntu)"
  apt-get --version | head -n1
elif command -v dnf >/dev/null 2>&1; then
  echo "Package manager: dnf (Fedora/RHEL)"
  dnf --version | head -n1
elif command -v zypper >/dev/null 2>&1; then
  echo "Package manager: zypper (openSUSE)"
  zypper --version | head -n1
elif command -v apk >/dev/null 2>&1; then
  echo "Package manager: apk (Alpine Linux)"
  apk --version | head -n1
else
  echo "Error: No supported package manager detected." >&2
  exit 1
fi
