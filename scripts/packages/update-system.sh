#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: update-system.sh [options]

Options:
  -h, --help     Show this help message and exit
  -n, --dry-run  Dry-run mode: display commands without executing them

Description:
  Updates the system using the detected package manager
  (pacman, apt, dnf, zypper, apk).
EOF
  exit 0
}

DRY_RUN=false

while (( "$#" )); do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -n|--dry-run)
      DRY_RUN=true
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      exit 1
      ;;
    *)
      echo "Error: Unexpected argument: $1" >&2
      exit 1
      ;;
  esac
  shift
done

run_cmd() {
  if $DRY_RUN; then
    echo "[DRY RUN] sudo $*"
  else
    sudo "$@"
  fi
}

# Detect package manager and perform update
if command -v pacman >/dev/null 2>&1; then
  echo "Detected Arch Linux (pacman)"
  run_cmd pacman -Syu --noconfirm
elif command -v apt-get >/dev/null 2>&1; then
  echo "Detected Debian/Ubuntu (apt-get)"
  run_cmd apt-get update
  run_cmd apt-get upgrade -y
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
  run_cmd zypper update -y
elif command -v apk >/dev/null 2>&1; then
  echo "Detected Alpine Linux (apk)"
  run_cmd apk update
  run_cmd apk upgrade
else
  echo "Error: Unsupported or no package manager detected." >&2
  exit 1
fi
