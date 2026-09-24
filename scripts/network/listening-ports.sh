#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options] [port]

Options:
  -h, --help   Show this help message and exit
  -p <port>    Specify a port number to filter results (optional)

Lists TCP and UDP ports that are currently listening on the system.
If a port is provided, only that port's listening entries are shown.
EOF
  exit 0
}

# Default values
filter_port=""

# Parse arguments
while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    -p)
      filter_port="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      ;;
  esac
done

# Choose command: ss preferred, fallback to netstat
if command -v ss >/dev/null 2>&1; then
  cmd="ss -tuln"
elif command -v netstat >/dev/null 2>&1; then
  cmd="netstat -tuln"
else
  echo "Neither ss nor netstat is available to list listening ports."
  exit 1
fi

if [[ -n "$filter_port" ]]; then
  $cmd | awk "{print} /:$filter_port\b/"
else
  $cmd
fi
