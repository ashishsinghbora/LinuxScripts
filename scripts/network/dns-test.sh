#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options] <hostname>

Options:
  -h, --help   Show this help message and exit
  -c <count>   Number of DNS queries to perform (default: 1)

Performs a DNS lookup for the given hostname using dig if available,
otherwise falls back to nslookup. Reports the resolved IP addresses.
EOF
  exit 0
}

# Default values
count=1

# Parse arguments
while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    -c)
      count="$2"
      shift 2
      ;;
    *)
      hostname="$1"
      shift
      ;;
  esac
done

if [[ -z "${hostname:-}" ]]; then
  echo "Error: hostname is required."
  show_help
fi

if command -v dig >/dev/null 2>&1; then
  echo "Using dig for DNS lookup..."
  dig +short "${hostname}" | head -n "$count"
elif command -v nslookup >/dev/null 2>&1; then
  echo "Using nslookup for DNS lookup..."
  nslookup "$hostname" | awk '/^Address: / {print $2}' | head -n "$count"
else
  echo "Neither dig nor nslookup is installed. Cannot perform DNS lookup."
  exit 1
fi
