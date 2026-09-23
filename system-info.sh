#!/usr/bin/env bash

set -euo pipefail

echo "================================"
echo "        SYSTEM INFORMATION"
echo "================================"

echo
echo "Hostname : $(hostname)"
echo "Kernel   : $(uname -r)"
echo "Arch     : $(uname -m)"
echo "Uptime   : $(uptime -p)"

if command -v lsb_release >/dev/null 2>&1; then
    echo "OS       : $(lsb_release -ds)"
elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "OS       : $PRETTY_NAME"
fi

echo "Shell    : ${SHELL##*/}"
echo "User     : $USER"

echo
echo "CPU:"
lscpu | grep -E 'Model name|CPU\(s\)' | head -n 2

echo
echo "Memory:"
free -h

echo
echo "Disk:"
df -h / | tail -n 1
