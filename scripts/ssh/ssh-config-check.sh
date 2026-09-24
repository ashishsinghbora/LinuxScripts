#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: ssh-config-check.sh [options]

Options:
  -h, --help    Show this help message and exit

Description:
  Validates the syntax of the user's SSH client configuration file (~/.ssh/config).
  It runs 'ssh -G <dummy-host>' which forces ssh to parse the config.
  Any syntax errors are reported. No changes are made.
EOF
  exit 0
}

for arg in "$@"; do
  case "$arg" in
    -h|--help) show_help ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

CONFIG_FILE="$HOME/.ssh/config"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "SSH config file not found at $CONFIG_FILE. Nothing to validate."
  exit 0
fi

# Use a dummy host to force parsing; ssh will ignore unknown host but parse config.
if ssh -G dummyhost >/dev/null 2>&1; then
  echo "SSH config syntax is valid."
else
  echo "SSH config contains syntax errors."
  exit 1
fi
