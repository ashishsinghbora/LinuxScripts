#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: ssh-key-setup.sh [options]

Options:
  -h, --help          Show this help message and exit
  -t, --type TYPE     Key type to generate (ed25519 or rsa; default: ed25519)
  -c, --comment TEXT  Key comment (default: user@hostname)
  -f, --force         Allow overwriting existing key (backs up original)
  -y, --yes           Skip confirmation prompts (requires -f if key exists)
  -p, --passphrase P  Specify key passphrase (empty string for no passphrase)

Description:
  Inspects existing SSH keys and generates a modern, secure SSH key pair.
  - Defaults to Ed25519 (or RSA-4096 if rsa is requested).
  - Never overwrites an existing key without confirmation and automatic backup.
  - Ensures correct file permissions (0700 for ~/.ssh, 0600 for private key).
EOF
  exit 0
}

KEY_TYPE="ed25519"
COMMENT=""
FORCE=false
AUTOYES=false
PASSPHRASE=""
PASSPHRASE_SET=false

while (( "$#" )); do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -t|--type)
      if [[ -n "${2-}" && "${2-}" != -* ]]; then
        KEY_TYPE="${2,,}"
        shift
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -c|--comment)
      if [[ -n "${2-}" && "${2-}" != -* ]]; then
        COMMENT="$2"
        shift
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -f|--force)
      FORCE=true
      ;;
    -y|--yes)
      AUTOYES=true
      ;;
    -p|--passphrase)
      if [[ $# -ge 2 ]]; then
        PASSPHRASE="$2"
        PASSPHRASE_SET=true
        shift
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      exit 1
      ;;
    *)
      echo "Error: Unexpected argument: $1" >&2
      exit 1
      ;;
  esac
  shift
done

# Validate key type
case "$KEY_TYPE" in
  ed25519|rsa) ;;
  *)
    echo "Error: Unsupported key type '$KEY_TYPE'. Supported types: ed25519, rsa." >&2
    exit 1
    ;;
esac

if ! command -v ssh-keygen >/dev/null 2>&1; then
  echo "Error: 'ssh-keygen' utility is not installed." >&2
  exit 1
fi

SSH_DIR="${HOME:-.}/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [[ -z "$COMMENT" ]]; then
  HNAME="$(hostname 2>/dev/null || uname -n)"
  UNAME="$(whoami 2>/dev/null || echo "user")"
  COMMENT="${UNAME}@${HNAME}"
fi

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
if [[ $existing_keys -eq 0 ]]; then
  echo "  (No existing public keys found)"
fi
echo ""

if [[ -f "$TARGET_KEY" ]]; then
  echo "Warning: Target key '$TARGET_KEY' already exists."
  if ! $FORCE; then
    echo "Aborted: Use -f / --force to allow overwriting this key." >&2
    exit 1
  fi

  if ! $AUTOYES; then
    read -r -p "Overwrite '$TARGET_KEY'? Existing key will be backed up. [y/N]: " confirm
    case "$confirm" in
      [yY]|[yY][eE][sS]) ;;
      *)
        echo "Operation cancelled."
        exit 0
        ;;
    esac
  fi

  # Create backup before overwrite
  BACKUP_TIME="$(date +%Y%m%d_%H%M%S)"
  cp -p "$TARGET_KEY" "${TARGET_KEY}.bak_${BACKUP_TIME}"
  if [[ -f "${TARGET_KEY}.pub" ]]; then
    cp -p "${TARGET_KEY}.pub" "${TARGET_KEY}.pub.bak_${BACKUP_TIME}"
  fi
  echo "Original key backed up to '${TARGET_KEY}.bak_${BACKUP_TIME}'"
  rm -f "$TARGET_KEY" "${TARGET_KEY}.pub"
fi

declare -a GEN_OPTS=(-t "$KEY_TYPE" -C "$COMMENT" -f "$TARGET_KEY")
if [[ "$KEY_TYPE" == "rsa" ]]; then
  GEN_OPTS+=(-b 4096)
fi

if $PASSPHRASE_SET; then
  GEN_OPTS+=(-N "$PASSPHRASE")
fi

echo "Generating $KEY_TYPE SSH key pair..."
ssh-keygen "${GEN_OPTS[@]}"

chmod 600 "$TARGET_KEY"
chmod 644 "${TARGET_KEY}.pub"

echo ""
echo "Key successfully generated!"
echo "Private key: $TARGET_KEY"
echo "Public key : $TARGET_KEY.pub"
echo ""
echo "Public key fingerprint:"
ssh-keygen -lf "${TARGET_KEY}.pub"
echo ""
echo "Public key contents:"
cat "${TARGET_KEY}.pub"
