#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: ssh-key-setup.sh [options]

Options:
  -h, --help          Show this help message and exit
  -t, --type TYPE     Key type to generate (ed25519 or rsa; default: ed25519)
  -c, --comment TEXT  Key comment (default: user@hostname)
  -f, --force         Overwrite existing key if present (with confirmation)

Description:
  Checks existing SSH keys and optionally generates a new secure key pair.
  Defaults to modern Ed25519 keys and never overwrites existing keys without confirmation.
EOF
  exit 0
}

KEY_TYPE="ed25519"
COMMENT=""
FORCE=false

while (( "$#" )); do
  case "$1" in
    -h|--help) show_help;;
    -t|--type)
      shift
      KEY_TYPE="${1:-ed25519}"
      ;;
    -c|--comment)
      shift
      COMMENT="${1:-}"
      ;;
    -f|--force) FORCE=true;;
    *) echo "Unknown option: $1" >&2; exit 1;;
  esac
  shift
done

if [[ -z "$COMMENT" ]]; then
  if command -v hostname >/dev/null 2>&1; then
    hname=$(hostname)
  else
    hname=$(uname -n)
  fi
  COMMENT="$(whoami)@$hname"
fi

SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

TARGET_KEY="$SSH_DIR/id_$KEY_TYPE"

echo "=== SSH Key Setup ==="
echo "Checking existing keys in $SSH_DIR:"
existing_keys=0
for pub in "$SSH_DIR"/*.pub; do
  if [[ -f "$pub" ]]; then
    echo "  Found: $pub"
    existing_keys=$((existing_keys + 1))
  fi
done

if [[ -f "$TARGET_KEY" ]]; then
  echo "Target key '$TARGET_KEY' already exists."
  if [[ "$FORCE" == false ]]; then
    echo "Use -f / --force to regenerate this key."
    exit 0
  fi
  read -rp "Are you sure you want to overwrite '$TARGET_KEY'? [y/N]: " confirm
  case "$confirm" in
    [yY]|[yY][eE][sS]) ;;
    *) echo "Operation cancelled."; exit 0;;
  esac
fi

if ! command -v ssh-keygen >/dev/null 2>&1; then
  echo "Error: 'ssh-keygen' command not found. Install openssh-client." >&2
  exit 1
fi

echo "Generating $KEY_TYPE SSH key pair..."
ssh-keygen -t "$KEY_TYPE" -C "$COMMENT" -f "$TARGET_KEY"

echo ""
echo "Key successfully generated!"
echo "Private key: $TARGET_KEY"
echo "Public key : $TARGET_KEY.pub"
echo ""
echo "Public key contents:"
cat "$TARGET_KEY.pub"
