#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: ssh-hardening-check.sh [options]

Options:
  -h, --help        Show this help message and exit
  -c, --config FILE Path to sshd_config (default: /etc/ssh/sshd_config)

Description:
  READ-ONLY security audit tool for OpenSSH daemon (sshd) configuration.
  Inspects key hardening recommendations (root login, password auth, empty passwords,
  authentication attempts, etc.) and reports findings with recommendations.
  NEVER modifies or rewrites configuration files.
EOF
  exit 0
}

CONFIG_FILE="/etc/ssh/sshd_config"

while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    -c|--config)
      shift
      CONFIG_FILE="${1:-/etc/ssh/sshd_config}"
      ;;
    *) echo "Unknown option: $1" >&2; exit 1;;
  esac
  shift
done

echo "=== SSH Daemon Security Hardening Audit ==="
echo "Target config: $CONFIG_FILE"
echo "Note: This check is strictly READ-ONLY."
echo ""

if [[ ! -r "$CONFIG_FILE" ]]; then
  if [[ -f "$CONFIG_FILE" ]]; then
    echo "Warning: $CONFIG_FILE exists but is not readable without root privileges."
    echo "Tip: Run with sudo or inspect as root to read the config."
    exit 0
  else
    echo "Notice: $CONFIG_FILE not found on this system."
    exit 0
  fi
fi

get_sshd_setting() {
  local key="$1"
  # Search active (uncommented) directives first, case-insensitive
  local val
  val=$(grep -i -E "^[[:space:]]*${key}[[:space:]]+" "$CONFIG_FILE" 2>/dev/null | tail -n 1 | awk '{print $2}' || true)
  if [[ -z "$val" && -d "/etc/ssh/sshd_config.d" ]]; then
    val=$(grep -h -i -E "^[[:space:]]*${key}[[:space:]]+" /etc/ssh/sshd_config.d/*.conf 2>/dev/null | tail -n 1 | awk '{print $2}' || true)
  fi
  echo "$val"
}

check_rule() {
  local name="$1"
  local key="$2"
  local recommended="$3"
  local current
  current=$(get_sshd_setting "$key")

  printf "%-32s " "$name:"
  if [[ -z "$current" ]]; then
    echo "DEFAULT / NOT SET (Recommended: $recommended)"
  elif [[ "${current,,}" == "${recommended,,}" ]]; then
    echo "PASS ($current)"
  else
    echo "WARN (Current: $current | Recommended: $recommended)"
  fi
}

check_rule "PermitRootLogin" "PermitRootLogin" "no"
check_rule "PasswordAuthentication" "PasswordAuthentication" "no"
check_rule "PermitEmptyPasswords" "PermitEmptyPasswords" "no"
check_rule "X11Forwarding" "X11Forwarding" "no"
check_rule "MaxAuthTries" "MaxAuthTries" "4"
check_rule "ClientAliveCountMax" "ClientAliveCountMax" "2"

echo ""
echo "Hardening check completed. All recommendations are advisory."
