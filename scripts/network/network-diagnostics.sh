#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: network-diagnostics.sh [options]

Options:
  -h, --help   Show this help message and exit

Description:
  Runs a comprehensive non-destructive network diagnostics suite:
    * Internet HTTP/HTTPS reachability
    * DNS resolution test
    * ICMP Ping connectivity
    * Gateway detection and reachability
  Clearly reports test status using [PASS], [FAIL], [SKIPPED], [UNKNOWN].
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

echo "=== Network Diagnostics Suite ==="
echo ""

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
UNKNOWN_COUNT=0

report_pass() {
  echo "  [PASS] $1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

report_fail() {
  echo "  [FAIL] $1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

report_skip() {
  echo "  [SKIPPED] $1"
  SKIP_COUNT=$((SKIP_COUNT + 1))
}

report_unknown() {
  echo "  [UNKNOWN] $1"
  UNKNOWN_COUNT=$((UNKNOWN_COUNT + 1))
}

# 1. Internet Connectivity
echo "[1/4] Checking internet reachability..."
if command -v curl >/dev/null 2>&1; then
  if curl -s -o /dev/null --connect-timeout 4 --max-time 6 "https://1.1.1.1" || curl -s -o /dev/null --connect-timeout 4 --max-time 6 "https://8.8.8.8"; then
    report_pass "Direct IP HTTPS reachability"
  else
    report_fail "Could not reach internet endpoints via HTTPS"
  fi
elif command -v wget >/dev/null 2>&1; then
  if wget -q --timeout=5 --spider "https://1.1.1.1" || wget -q --timeout=5 --spider "https://8.8.8.8"; then
    report_pass "Direct IP HTTPS reachability (wget)"
  else
    report_fail "Could not reach internet endpoints via HTTPS (wget)"
  fi
else
  report_skip "Neither curl nor wget is installed"
fi

# 2. DNS Resolution
echo "[2/4] Testing DNS resolution..."
TEST_DOMAINS=("cloudflare.com" "google.com")
DNS_SUCCESS=false

if command -v dig >/dev/null 2>&1; then
  for dom in "${TEST_DOMAINS[@]}"; do
    if dig +short +time=3 +tries=1 "$dom" 2>/dev/null | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'; then
      report_pass "Resolved $dom via dig"
      DNS_SUCCESS=true
      break
    fi
  done
  if ! $DNS_SUCCESS; then
    report_fail "DNS resolution failed for test domains via dig"
  fi
elif command -v nslookup >/dev/null 2>&1; then
  for dom in "${TEST_DOMAINS[@]}"; do
    if nslookup "$dom" 2>/dev/null | awk '/^Address: / {print $2}' | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'; then
      report_pass "Resolved $dom via nslookup"
      DNS_SUCCESS=true
      break
    fi
  done
  if ! $DNS_SUCCESS; then
    report_fail "DNS resolution failed for test domains via nslookup"
  fi
elif command -v getent >/dev/null 2>&1; then
  if getent hosts "${TEST_DOMAINS[0]}" >/dev/null 2>&1; then
    report_pass "Resolved ${TEST_DOMAINS[0]} via getent hosts"
  else
    report_fail "DNS resolution failed via getent"
  fi
else
  report_skip "No DNS diagnostic tool (dig/nslookup/getent) available"
fi

# 3. ICMP Ping Test
echo "[3/4] Testing ICMP reachability..."
if command -v ping >/dev/null 2>&1; then
  # Try pinging 1.1.1.1 or 8.8.8.8 (1 packet, 3s timeout)
  if ping -c 1 -W 3 1.1.1.1 >/dev/null 2>&1 || ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
    report_pass "ICMP ping to public resolver responded"
  else
    # ICMP is frequently filtered by cloud firewalls / ISP networks
    report_unknown "Ping unacknowledged (ICMP may be filtered by firewall or network policy)"
  fi
else
  report_skip "ping utility is not installed"
fi

# 4. Default Gateway Reachability
echo "[4/4] Checking default gateway..."
GATEWAY=""
if command -v ip >/dev/null 2>&1; then
  GATEWAY="$(ip route 2>/dev/null | awk '/default/ {print $3}' | head -n1 || true)"
fi

if [[ -n "$GATEWAY" ]]; then
  if command -v ping >/dev/null 2>&1; then
    if ping -c 1 -W 2 "$GATEWAY" >/dev/null 2>&1; then
      report_pass "Default gateway ($GATEWAY) is responsive to ping"
    else
      report_unknown "Default gateway ($GATEWAY) detected but does not respond to ping"
    fi
  else
    report_pass "Default gateway detected: $GATEWAY (ping tool not available to verify)"
  fi
else
  report_skip "No default gateway route detected in routing table"
fi

echo ""
echo "=== Diagnostic Summary ==="
echo "Passed:   $PASS_COUNT"
echo "Failed:   $FAIL_COUNT"
echo "Skipped:  $SKIP_COUNT"
echo "Unknown:  $UNKNOWN_COUNT"

if [[ $FAIL_COUNT -gt 0 ]]; then
  exit 1
fi
exit 0
