#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: process-info.sh [options] [pid|name]

Options:
  -h, --help       Show this help message and exit
  -u, --user USER  Filter processes by user
  -a, --all        Show all processes with full details

Description:
  Displays detailed process information.
  - If a PID is specified, displays status, memory, CPU, and command details for that PID.
  - If a process name is specified, lists matching processes.
  - If no target is specified, displays top resource-consuming processes.
EOF
  exit 0
}

TARGET=""
USER_FILTER=""
SHOW_ALL=false

while (( "$#" )); do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -u|--user)
      if [[ -n "${2-}" && "${2-}" != -* ]]; then
        USER_FILTER="$2"
        shift
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -a|--all)
      SHOW_ALL=true
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      exit 1
      ;;
    *)
      if [[ -z "$TARGET" ]]; then
        TARGET="$1"
      else
        echo "Error: Unexpected additional argument: $1" >&2
        exit 1
      fi
      ;;
  esac
  shift
done

if ! command -v ps >/dev/null 2>&1; then
  echo "Error: 'ps' command not found." >&2
  exit 1
fi

# Case 1: Target PID provided
if [[ -n "$TARGET" && "$TARGET" =~ ^[0-9]+$ ]]; then
  if ! kill -0 "$TARGET" 2>/dev/null; then
    echo "Error: Process with PID $TARGET does not exist." >&2
    exit 1
  fi
  echo "=== Process Details for PID $TARGET ==="
  ps -p "$TARGET" -o pid,user,%cpu,%mem,stat,start,time,comm,args
  exit 0
fi

# Case 2: Target process name provided
if [[ -n "$TARGET" ]]; then
  echo "=== Searching processes matching '$TARGET' ==="
  MATCHES="$(pgrep -l -f "$TARGET" 2>/dev/null || true)"
  if [[ -z "$MATCHES" ]]; then
    echo "Error: No processes matching '$TARGET' found." >&2
    exit 1
  fi
  echo "$MATCHES"
  exit 0
fi

# Case 3: Show all or filtered by user
if $SHOW_ALL; then
  echo "=== All Running Processes ==="
  if [[ -n "$USER_FILTER" ]]; then
    ps -u "$USER_FILTER" -o pid,user,%cpu,%mem,stat,start,time,comm
  else
    ps -eo pid,user,%cpu,%mem,stat,start,time,comm
  fi
  exit 0
fi

if [[ -n "$USER_FILTER" ]]; then
  echo "=== Processes for User '$USER_FILTER' ==="
  ps -u "$USER_FILTER" -o pid,user,%cpu,%mem,stat,start,time,comm
  exit 0
fi

# Case 4: Default overview (top CPU and Memory)
echo "=== Top Processes by CPU Usage ==="
ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 10
echo ""
echo "=== Top Processes by Memory Usage ==="
ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -n 10
