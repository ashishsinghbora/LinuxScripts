#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: system-health.sh [options]

Options:
  -h, --help   Show this help message and exit

Description:
  Displays a quick overview of system health indicators including
  load average, memory usage, root disk usage, and top processes.
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

echo "=== System Health Overview ==="
echo ""

# Load average
if command -v uptime >/dev/null 2>&1; then
  echo "Load average: $(uptime | awk -F'load average:' '{print $2}' | sed 's/^ //')"
fi

# Memory usage
if command -v free >/dev/null 2>&1; then
  echo ""
  echo "Memory usage:"
  free -h
fi

# Disk usage (root)
if command -v df >/dev/null 2>&1; then
  echo ""
  echo "Disk usage (root):"
  df -h /
fi

# Top CPU consuming processes
if command -v ps >/dev/null 2>&1; then
  echo ""
  echo "Top CPU processes:"
  (ps -eo pid,comm,%cpu --sort=-%cpu 2>/dev/null || true) | head -n 6 || true
fi

# Top memory consuming processes
if command -v ps >/dev/null 2>&1; then
  echo ""
  echo "Top memory processes:"
  (ps -eo pid,comm,%mem --sort=-%mem 2>/dev/null || true) | head -n 6 || true
fi
