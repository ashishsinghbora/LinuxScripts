#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options]

Options:
  -h, --help   Show this help message and exit

Runs a quick network diagnostics suite:
  * Checks internet connectivity (curl or wget)
  * Performs a DNS lookup for a default host (google.com)
  * Pings a default IP (8.8.8.8)
  * Checks common ports (80, 443) on the default gateway
The script reports success/failure for each step but never modifies the system.
EOF
  exit 0
}

# Default values
host="google.com"
ping_ip="8.8.8.8"
ports="80 443"

# Parse arguments
while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    *) echo "Unknown option: $1"; show_help;;
  esac
  shift
done

echo "--- Network diagnostics start ---"

# 1. Internet connectivity
if command -v curl >/dev/null 2>&1; then
  echo "Testing internet reachability with curl..."
  if curl -s -o /dev/null --max-time 5 "https://www.google.com"; then
    echo "Internet reachable (curl)."
  else
    echo "Internet NOT reachable (curl)."
  fi
elif command -v wget >/dev/null 2>&1; then
  echo "Testing internet reachability with wget..."
  if wget -q --timeout=5 --spider "https://www.google.com"; then
    echo "Internet reachable (wget)."
  else
    echo "Internet NOT reachable (wget)."
  fi
else
  echo "Neither curl nor wget installed; skipping internet test."
fi

# 2. DNS lookup
if command -v dig >/dev/null 2>&1; then
  echo "Performing DNS lookup for $host..."
  dig +short "$host" | head -n 3 || echo "DNS lookup failed."
elif command -v nslookup >/dev/null 2>&1; then
  echo "Performing DNS lookup for $host..."
  nslookup "$host" | awk '/^Address: / {print $2}' | head -n 3 || echo "DNS lookup failed."
else
  echo "Neither dig nor nslookup installed; skipping DNS test."
fi

# 3. Ping test
if command -v ping >/dev/null 2>&1; then
  echo "Pinging $ping_ip..."
  if ping -c 2 "$ping_ip" >/dev/null; then
    echo "Ping successful."
  else
    echo "Ping failed."
  fi
else
  echo "ping command not found; skipping ping test."
fi

# 4. Port checks on default gateway (if reachable)
if command -v ip >/dev/null 2>&1; then
  gateway=$(ip route | awk '/default/ {print $3}' | head -n1 || true)
  if [[ -n "$gateway" ]]; then
    echo "Default gateway detected: $gateway"
    for p in $ports; do
      echo "Checking TCP port $p on $gateway..."
      if command -v nc >/dev/null 2>&1; then
        nc -z -w2 "$gateway" "$p" && echo "Port $p open" || echo "Port $p closed"
      elif command -v timeout >/dev/null 2>&1 && command -v bash >/dev/null 2>&1; then
        timeout 2 bash -c "</dev/tcp/$gateway/$p" && echo "Port $p open" || echo "Port $p closed"
      else
        echo "No tool available to test ports (nc or /dev/tcp)."
        break
      fi
    done
  else
    echo "Could not determine default gateway; skipping port checks."
  fi
else
  echo "ip command not found; cannot determine default gateway."
fi

echo "--- Network diagnostics end ---"
