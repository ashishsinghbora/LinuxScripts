#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: git-info.sh [options]

Options:
  -h, --help    Show this help message and exit

Description:
  Displays Git version, global user configuration, and if executed within
  a Git repository, shows current branch, remote status, and working tree state.
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

if ! command -v git >/dev/null 2>&1; then
  echo "Error: 'git' command not found. Please install git." >&2
  exit 1
fi

echo "=== Git Information ==="
git --version

echo ""
echo "Global Configuration:"
name=$(git config --global user.name 2>/dev/null || echo "Not set")
email=$(git config --global user.email 2>/dev/null || echo "Not set")
echo "  user.name : $name"
echo "  user.email: $email"

echo ""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Current Repository Status:"
  echo "  Root Directory: $(git rev-parse --show-toplevel)"
  echo "  Current Branch: $(git branch --show-current 2>/dev/null || echo "detached")"
  remotes=$(git remote -v 2>/dev/null | head -n 2 || true)
  if [[ -n "$remotes" ]]; then
    echo "  Remotes:"
    echo "$remotes" | sed 's/^/    /'
  fi
  echo "  Latest Commit :"
  git log -1 --oneline 2>/dev/null | sed 's/^/    /' || echo "    No commits yet"
  echo "  Working Tree Status:"
  git status --short | sed 's/^/    /' || true
else
  echo "Notice: Current directory is not inside a Git repository."
fi
