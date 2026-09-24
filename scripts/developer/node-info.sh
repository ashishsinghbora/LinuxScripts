#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: node-info.sh [options]

Options:
  -h, --help    Show this help message and exit

Description:
  Displays Node.js and NPM versions, global packages installed, and
  detects alternative package managers (yarn, pnpm, bun).
EOF
  exit 0
}

while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    *) echo "Unknown option: $1" >&2; exit 1;;
  esac
  shift
done

echo "=== Node.js Environment Information ==="

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js is not installed."
  exit 0
fi

echo "Node Version : $(node --version)"
echo "Node Path    : $(command -v node)"

if command -v npm >/dev/null 2>&1; then
  echo "NPM Version  : $(npm --version)"
  echo ""
  echo "Global NPM packages (depth=0):"
  npm list -g --depth=0 2>/dev/null | tail -n +2 | head -n 15 | sed 's/^/  /' || echo "  None or inaccessible"
fi

echo ""
echo "Alternative Package Managers:"
for mgr in yarn pnpm bun; do
  if command -v "$mgr" >/dev/null 2>&1; then
    echo "  $mgr: $($mgr --version 2>/dev/null || echo "installed")"
  else
    echo "  $mgr: Not installed"
  fi
done
