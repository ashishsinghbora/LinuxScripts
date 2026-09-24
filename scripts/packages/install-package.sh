#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: install-package.sh [options] <package_name>

Options:
  -h, --help    Show this help message and exit
  -y, --yes     Automatically answer yes to any prompts
  -n, --dry-run Show the command that would be run without installing

Description:
  Installs the specified package using the detected package manager
  (pacman, apt, dnf, zypper, apk). Prompts for confirmation unless
  -y or --yes is provided.
EOF
  exit 0
}

AUTOYES=false
DRY_RUN=false
PACKAGE=""

while (( "$#" )); do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -y|--yes)
      AUTOYES=true
      ;;
    -n|--dry-run)
      DRY_RUN=true
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      exit 1
      ;;
    *)
      if [[ -z "$PACKAGE" ]]; then
        PACKAGE="$1"
      else
        echo "Error: Unexpected additional argument: $1" >&2
        exit 1
      fi
      ;;
  esac
  shift
done

if [[ -z "$PACKAGE" ]]; then
  echo "Error: package name required." >&2
  echo "Run '$0 --help' for usage." >&2
  exit 1
fi

declare -a INSTALL_CMD=()
PM=""

if command -v pacman >/dev/null 2>&1; then
  PM="pacman"
  INSTALL_CMD=(pacman -S --noconfirm)
elif command -v apt-get >/dev/null 2>&1; then
  PM="apt"
  INSTALL_CMD=(apt-get install -y)
elif command -v apt >/dev/null 2>&1; then
  PM="apt"
  INSTALL_CMD=(apt install -y)
elif command -v dnf >/dev/null 2>&1; then
  PM="dnf"
  INSTALL_CMD=(dnf install -y)
elif command -v zypper >/dev/null 2>&1; then
  PM="zypper"
  INSTALL_CMD=(zypper install -y)
elif command -v apk >/dev/null 2>&1; then
  PM="apk"
  INSTALL_CMD=(apk add)
else
  echo "Error: Unsupported or no package manager detected." >&2
  exit 1
fi

echo "Detected package manager: $PM"

if $DRY_RUN; then
  echo "[DRY RUN] sudo ${INSTALL_CMD[*]} $PACKAGE"
  exit 0
fi

if $AUTOYES; then
  sudo "${INSTALL_CMD[@]}" "$PACKAGE"
else
  read -r -p "Proceed to install '$PACKAGE' using $PM? [y/N] " resp
  case "$resp" in
    y|Y|yes|YES)
      sudo "${INSTALL_CMD[@]}" "$PACKAGE"
      ;;
    *)
      echo "Installation aborted."
      exit 0
      ;;
  esac
fi
