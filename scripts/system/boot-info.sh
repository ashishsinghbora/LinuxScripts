#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options]

Options:
  -h, --help   Show this help message and exit

Displays recent boot performance information using systemd-analyze and recent boot logs.
EOF
  exit 0
}

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    -h|--help) show_help ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

if command -v systemd-analyze >/dev/null 2>&1; then
  echo "Boot time breakdown:" && systemd-analyze blame
  echo -e "\nCritical chain:" && systemd-analyze critical-chain
else
  echo "systemd-analyze not available on this system."
fi

if command -v journalctl >/dev/null 2>&1; then
  echo -e "\nRecent boot log (last 20 lines):"
  journalctl -b -n 20
elif [[ -f /var/log/boot.log ]]; then
  echo -e "\nRecent boot log (last 20 lines) from /var/log/boot.log:"
  tail -n 20 /var/log/boot.log
else
  echo "No boot log accessible."
fi
