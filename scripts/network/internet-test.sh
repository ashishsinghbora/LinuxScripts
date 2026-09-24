#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options] [URL]

Options:
  -h, --help   Show this help message and exit
  -t <seconds> Timeout for the connection test (default: 5)

Performs a basic Internet connectivity test by attempting to fetch the
provided URL (default: https://www.google.com) using curl or wget. It
reports success or failure and the HTTP status code if reachable.
EOF
  exit 0
}

# Default values
url="https://www.google.com"
timeout=5

# Parse arguments
while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    -t)
      timeout="$2"
      shift 2
      ;;
    *)
      url="$1"
      shift
      ;;
  esac
done

if command -v curl >/dev/null 2>&1; then
  echo "Testing connectivity to $url using curl..."
  if curl -s -o /dev/null -w "%{http_code}" --max-time "$timeout" "$url" | grep -q "^[23][0-9][0-9]$"; then
    echo "Internet connectivity OK (HTTP success)."
    exit 0
  else
    echo "Failed to reach $url (curl reported non‑2xx/3xx)."
    exit 1
  fi
elif command -v wget >/dev/null 2>&1; then
  echo "Testing connectivity to $url using wget..."
  if wget -q --timeout=$timeout --spider "$url"; then
    echo "Internet connectivity OK (wget succeeded)."
    exit 0
  else
    echo "Failed to reach $url (wget failed)."
    exit 1
  fi
else
  echo "Neither curl nor wget is installed. Cannot perform Internet test."
  exit 1
fi
