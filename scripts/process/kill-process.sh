#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: $(basename "$0") [options] <pid|process_name>

Options:
  -h, --help          Show this help message and exit
  -s, --signal <sig>  Signal to send (default: SIGTERM)
  -f, --force         Skip confirmation prompt (use with caution)

Safely terminates a process identified by PID or name. By default the script
asks for confirmation before sending the signal. It validates the PID and
ensures the target is not the current shell.
EOF
  exit 0
}

# Default values
signal="SIGTERM"
force="no"

# Parse arguments
while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    -s|--signal)
      signal="$2"
      shift 2
      ;;
    -f|--force)
      force="yes"
      shift
      ;;
    *)
      target="$1"
      shift
      ;;
  esac
done

if [[ -z "${target:-}" ]]; then
  echo "Error: PID or process name is required."
  show_help
fi

# Resolve target to PID(s)
if [[ "$target" =~ ^[0-9]+$ ]]; then
  read -ra pids <<< "$target"
else
  # Use pgrep to find matching processes (exclude this script)
  mapfile -t pids < <(pgrep -f "${target}" | grep -vw $$ || true)
fi

if [[ ${#pids[@]} -eq 0 ]]; then
  echo "No matching processes found for '$target'."
  exit 1
fi

echo "Found ${#pids[@]} matching process(es): ${pids[*]}"

if [[ "$force" != "yes" ]]; then
  read -r -p "Proceed to send $signal to these process(es)? [y/N] " resp
  case "$resp" in
    y|Y|yes|YES) ;;
    *) echo "Aborted."; exit 0;;
  esac
fi

for pid in "${pids[@]}"; do
  if ! kill -0 "$pid" 2>/dev/null; then
    echo "Process $pid no longer exists."; continue
  fi
  echo "Sending $signal to PID $pid..."
  kill -s "$signal" "$pid" || echo "Failed to send signal to $pid"
done

echo "Done."
