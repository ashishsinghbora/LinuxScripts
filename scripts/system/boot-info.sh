#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: boot-info.sh [options]

Options:
  -h, --help   Show this help message and exit

Description:
  Displays recent boot performance information using systemd-analyze
  and recent boot logs (journalctl or /var/log/boot.log).
  Gracefully handles containers or environments where systemd is not running.
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

echo "=== System Boot Information ==="
echo ""

if command -v systemd-analyze >/dev/null 2>&1; then
  echo "Boot time breakdown:"
  systemd-analyze blame 2>/dev/null | head -n 15 || echo "  (systemd-analyze blame not available; systemd may not be running or boot incomplete)"
  echo ""
  echo "Critical chain:"
  systemd-analyze critical-chain 2>/dev/null || echo "  (critical-chain not available)"
else
  echo "systemd-analyze not available on this system."
fi

echo ""
if command -v journalctl >/dev/null 2>&1; then
  echo "Recent boot log (last 20 lines):"
  journalctl -b -n 20 2>/dev/null || echo "  (journalctl boot logs not accessible)"
elif [[ -f /var/log/boot.log ]]; then
  echo "Recent boot log from /var/log/boot.log:"
  tail -n 20 /var/log/boot.log 2>/dev/null || echo "  (unable to read /var/log/boot.log)"
else
  echo "No boot log accessible."
fi
