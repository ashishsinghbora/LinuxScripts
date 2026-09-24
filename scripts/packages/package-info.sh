#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: package-info.sh [options] <package_name>

Options:
  -h, --help    Show this help message and exit

Description:
  Shows detailed information about the specified package using the detected
  package manager (pacman, apt, dnf, zypper, apk).
EOF
  exit 0
}

PKG=""

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
      if [[ -z "$PKG" ]]; then
        PKG="$1"
      else
        echo "Error: Unexpected additional argument: $1" >&2
        exit 1
      fi
      ;;
  esac
  shift
done

if [[ -z "$PKG" ]]; then
  echo "Error: package name required." >&2
  echo "Run '$0 --help' for usage." >&2
  exit 1
fi

if command -v pacman >/dev/null 2>&1; then
  # Try local query first, fallback to sync database if not installed
  pacman -Qi "$PKG" 2>/dev/null || pacman -Si "$PKG"
elif command -v apt >/dev/null 2>&1; then
  apt show "$PKG"
elif command -v apt-cache >/dev/null 2>&1; then
  apt-cache show "$PKG"
elif command -v dnf >/dev/null 2>&1; then
  dnf info "$PKG"
elif command -v zypper >/dev/null 2>&1; then
  zypper info "$PKG"
elif command -v apk >/dev/null 2>&1; then
  apk info -d "$PKG"
else
  echo "Error: Unsupported or no package manager detected." >&2
  exit 1
fi
