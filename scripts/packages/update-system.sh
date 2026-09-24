#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [OPTIONS]

Options:
  -h          Show this help message and exit
  -n          Dry‑run mode: display the commands that would be run without executing them

Updates the system using the detected package manager (pacman, apt, dnf, zypper).
EOF
  exit 0
}

# Default values
DRY_RUN=false

# Parse options
while getopts "hn" opt; do
  case "$opt" in
    h) show_help ;;
    n) DRY_RUN=true ;;
    *) show_help ;;
  esac
done

run_cmd() {
  if $DRY_RUN; then
    echo "[DRY RUN] $*"
  else
    sudo "$@"
  fi
}

# Detect package manager and perform update
if command -v pacman >/dev/null 2>&1; then
  echo "Detected Arch Linux (pacman)"
  run_cmd pacman -Syu
elif command -v apt >/dev/null 2>&1; then
  echo "Detected Debian/Ubuntu (apt)"
  run_cmd apt update
  run_cmd apt upgrade -y
elif command -v dnf >/dev/null 2>&1; then
  echo "Detected Fedora/RHEL (dnf)"
  run_cmd dnf upgrade -y
elif command -v zypper >/dev/null 2>&1; then
  echo "Detected openSUSE (zypper)"
  run_cmd zypper refresh
  run_cmd zypper update
else
  echo "Unsupported package manager."
  exit 1
fi
