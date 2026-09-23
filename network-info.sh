#!/usr/bin/env bash

set -euo pipefail

echo "================================"
echo "        NETWORK INFORMATION"
echo "================================"

echo
echo "Hostname:"
hostname

echo
echo "Interfaces:"
ip -brief address

echo
echo "Default route:"
ip route | grep default || echo "No default route found."

echo
echo "DNS:"
if command -v resolvectl >/dev/null 2>&1; then
    resolvectl status | grep -E 'DNS Servers|Current DNS Server' || true
elif [[ -f /etc/resolv.conf ]]; then
    grep '^nameserver' /etc/resolv.conf || true
fi
