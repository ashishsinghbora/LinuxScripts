#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: network-info.sh [options]

Options:
  -h, --help    Show this help message and exit

Description:
  Displays information about network hostname, network interfaces, IP addresses,
  default routing, and active DNS servers.
EOF
  exit 0
}

for arg in "$@"; do
  case "$arg" in
    -h|--help) show_help ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

get_hostname() {
  if command -v hostname >/dev/null 2>&1; then
    hostname
  else
    uname -n
  fi
}

echo "================================"
echo "      NETWORK INFORMATION       "
echo "================================"
echo ""
echo "Hostname:"
get_hostname

echo ""
echo "Interfaces:"
if command -v ip >/dev/null 2>&1; then
  ip -brief address || ip addr
elif command -v ifconfig >/dev/null 2>&1; then
  ifconfig
else
  echo "Neither 'ip' nor 'ifconfig' command found."
fi

echo ""
echo "Default route:"
if command -v ip >/dev/null 2>&1; then
  ip route | grep default || echo "No default route found."
elif command -v route >/dev/null 2>&1; then
  route -n | grep -E '^0.0.0.0' || echo "No default route found."
else
  echo "Routing tools not available."
fi

echo ""
echo "DNS:"
if command -v resolvectl >/dev/null 2>&1; then
  resolvectl status 2>/dev/null | grep -E 'DNS Servers|Current DNS Server' || true
elif [[ -f /etc/resolv.conf ]]; then
  grep '^nameserver' /etc/resolv.conf || true
else
  echo "DNS configuration not found."
fi
