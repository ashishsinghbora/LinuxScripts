#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: kill-process.sh [options] <pid|process_name>

Options:
  -h, --help          Show this help message and exit
  -s, --signal <sig>  Signal to send (default: SIGTERM)
  -f, --force         Skip confirmation prompt (use with caution)

Description:
  Safely terminates a process identified by PID or name.
  - Prompts for confirmation unless -f / --force is given.
  - Safeguards against terminating init (PID 1), current shell ($$),
    or parent process ($PPID).
EOF
  exit 0
}

signal="SIGTERM"
force="no"
target=""

while (( "$#" )); do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -s|--signal)
      if [[ -n "${2-}" && "${2-}" != -* ]]; then
        signal="$2"
        shift
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -f|--force)
      force="yes"
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      exit 1
      ;;
    *)
      if [[ -z "$target" ]]; then
        target="$1"
      else
        echo "Error: Unexpected additional argument: $1" >&2
        exit 1
      fi
      ;;
  esac
  shift
done

if [[ -z "$target" ]]; then
  echo "Error: PID or process name is required." >&2
  echo "Run '$0 --help' for usage." >&2
  exit 1
fi

# Validate signal
if ! kill -l "$signal" >/dev/null 2>&1; then
  echo "Error: Invalid signal '$signal'." >&2
  exit 1
fi

declare -a pids=()

# Resolve target to PID(s)
if [[ "$target" =~ ^[0-9]+$ ]]; then
  if [[ "$target" -eq 1 ]]; then
    echo "Error: Refusing to send signal to PID 1 (init/systemd)." >&2
    exit 1
  fi
  if [[ "$target" -eq 0 ]]; then
    echo "Error: Refusing to send signal to PID 0." >&2
    exit 1
  fi
  if [[ "$target" -eq $$ || "$target" -eq $PPID ]]; then
    echo "Error: Refusing to send signal to self ($$) or parent ($PPID)." >&2
    exit 1
  fi
  pids=("$target")
else
  # Use pgrep to find matching processes, filtering out self and parent
  while IFS= read -r matched_pid; do
    [[ -z "$matched_pid" ]] && continue
    if [[ "$matched_pid" -ne $$ && "$matched_pid" -ne $PPID && "$matched_pid" -ne 1 ]]; then
      pids+=("$matched_pid")
    fi
  done < <(pgrep -f "${target}" || true)
fi

if [[ ${#pids[@]} -eq 0 ]]; then
  echo "No matching eligible processes found for '$target'."
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
    echo "Process $pid no longer exists."
    continue
  fi
  echo "Sending $signal to PID $pid..."
  kill -s "$signal" "$pid" || echo "Failed to send signal to $pid"
done

echo "Done."
