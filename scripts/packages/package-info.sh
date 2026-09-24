#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options] <package_name>

Options:
  -h          Show this help message and exit

Shows detailed information about the specified package using the detected
package manager. The script does not modify the system.
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
  echo "Error: package name required."
  show_help
fi

PKG="$1"

if command -v pacman >/dev/null 2>&1; then
  pacman -Qi "$PKG"
elif command -v apt >/dev/null 2>&1; then
  apt show "$PKG"
elif command -v dnf >/dev/null 2>&1; then
  dnf info "$PKG"
elif command -v zypper >/dev/null 2>&1; then
  zypper info "$PKG"
else
  echo "Unsupported package manager."
  exit 1
fi
