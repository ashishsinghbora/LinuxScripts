#!/usr/bin/env bash

set -euo pipefail

show_help() {
    cat <<'EOF'
Usage: $(basename "$0") [OPTIONS]

Display a quick overview of system health indicators.

Options:
  -h    Show this help message
EOF
}

if [[ "${1-}" == "-h" ]]; then
    show_help
    exit 0
fi

echo "=== System Health Overview ==="

# Load average
if command -v uptime >/dev/null 2>&1; then
    echo "Load average: $(uptime | awk -F'load average:' '{print $2}' | sed 's/^ //')"
fi

# Memory usage
if command -v free >/dev/null 2>&1; then
    echo "Memory usage:" && free -h
fi

# Disk usage (root)
if command -v df >/dev/null 2>&1; then
    echo "Disk usage (root):" && df -h /
fi

# Top CPU consuming processes (non-root)
if command -v ps >/dev/null 2>&1; then
    echo "Top CPU processes:" && ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
fi

# Top memory consuming processes
if command -v ps >/dev/null 2>&1; then
    echo "Top memory processes:" && ps -eo pid,comm,%mem --sort=-%mem | head -n 6
fi
