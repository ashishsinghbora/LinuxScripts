#!/usr/bin/env bash

set -euo pipefail

show_help() {
    cat <<'EOF'
Usage: $(basename "$0") [OPTIONS]

Clean temporary files and display cache information.

Options:
  -h    Show this help message
EOF
}

if [[ "${1-}" == "-h" ]]; then
    show_help
    exit 0
fi

echo "Cleaning temporary files..."

if [[ -d /tmp ]]; then
    find /tmp -mindepth 1 -maxdepth 1 -user "$USER" -exec rm -rf -- {} +
fi

if command -v pacman >dev/null 2>&1; then
    echo
    echo "Pacman cache:"
    du -sh /var/cache/pacman/pkg 2>/dev/null || true
    echo
    echo "Use 'sudo paccache -r' to safely remove old package versions."
fi

echo
echo "Cleanup completed."
echo "Cleaning temporary files..."

if [[ -d /tmp ]]; then
    find /tmp -mindepth 1 -maxdepth 1 -user "$USER" -exec rm -rf -- {} +
fi

if command -v pacman >/dev/null 2>&1; then
    echo
    echo "Pacman cache:"
    du -sh /var/cache/pacman/pkg 2>/dev/null || true
    echo
    echo "Use 'sudo paccache -r' to safely remove old package versions."
fi

echo
echo "Cleanup completed."
