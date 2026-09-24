#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: system-info.sh [options]

Options:
  -h, --help    Show this help message and exit

Description:
  Displays basic system information including OS distribution, hostname,
  kernel version, architecture, uptime, CPU, memory, and root disk usage.
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

get_hostname() {
  if command -v hostname >/dev/null 2>&1; then
    hostname
  else
    uname -n
  fi
}

echo "================================"
echo "      SYSTEM INFORMATION        "
echo "================================"
echo ""
echo "Hostname : $(get_hostname)"
echo "Kernel   : $(uname -r)"
echo "Arch     : $(uname -m)"
echo "Uptime   : $(uptime -p 2>/dev/null || uptime)"

if command -v lsb_release >/dev/null 2>&1; then
  echo "OS       : $(lsb_release -ds)"
elif [[ -f /etc/os-release ]]; then
  # shellcheck source=/dev/null
  . /etc/os-release
  echo "OS       : ${PRETTY_NAME:-Linux}"
else
  echo "OS       : $(uname -s)"
fi

echo "Shell    : ${SHELL##*/}"
echo "User     : ${USER:-$(whoami)}"

echo ""
echo "CPU:"
if command -v lscpu >/dev/null 2>&1; then
  lscpu | grep -E 'Model name|CPU\(s\):' | head -n 2
else
  grep -m 1 "model name" /proc/cpuinfo 2>/dev/null || echo "Unknown CPU"
fi

echo ""
echo "Memory:"
if command -v free >/dev/null 2>&1; then
  free -h
else
  cat /proc/meminfo | head -n 3
fi

echo ""
echo "Root Disk:"
df -h / | tail -n 1
