#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: cleanup-cache.sh [options]

Options:
  -h, --help     Show this help message and exit
  -n, --dry-run  Show cache sizes and actions without deleting anything
  -y, --yes      Automatically confirm cleanup without prompting

Description:
  Inspects and cleans user cache directories (thumbnail cache, trash)
  and reports package manager / system journal cache usage with
  recommended maintenance commands.
  Never deletes critical system sockets or running process locks.
EOF
  exit 0
}

DRY_RUN=false
AUTOYES=false

while (( "$#" )); do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -n|--dry-run)
      DRY_RUN=true
      ;;
    -y|--yes)
      AUTOYES=true
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

echo "=== Cache & Temporary Files Inspector ==="
echo ""

# 1. User thumbnail cache
THUMB_CACHE="${HOME:-}/.cache/thumbnails"
if [[ -d "$THUMB_CACHE" ]]; then
  THUMB_SIZE="$(du -sh "$THUMB_CACHE" 2>/dev/null | cut -f1 || echo "0B")"
  echo "User thumbnail cache: $THUMB_CACHE (Size: $THUMB_SIZE)"
  if $DRY_RUN; then
    echo "[DRY RUN] Would clean thumbnail files in $THUMB_CACHE"
  elif $AUTOYES; then
    find "$THUMB_CACHE" -type f -delete 2>/dev/null || true
    echo "  Cleaned thumbnail cache."
  else
    read -r -p "Clean user thumbnail cache? [y/N] " resp
    case "$resp" in
      y|Y|yes|YES)
        find "$THUMB_CACHE" -type f -delete 2>/dev/null || true
        echo "  Cleaned thumbnail cache."
        ;;
      *)
        echo "  Skipped thumbnail cache."
        ;;
    esac
  fi
else
  echo "User thumbnail cache: None found."
fi

# 2. User Trash
TRASH_DIR="${HOME:-}/.local/share/Trash"
if [[ -d "$TRASH_DIR" ]]; then
  TRASH_SIZE="$(du -sh "$TRASH_DIR" 2>/dev/null | cut -f1 || echo "0B")"
  echo "User trash: $TRASH_DIR (Size: $TRASH_SIZE)"
  if $DRY_RUN; then
    echo "[DRY RUN] Would empty user trash in $TRASH_DIR"
  elif $AUTOYES; then
    rm -rf "${TRASH_DIR:?}"/files/* "${TRASH_DIR:?}"/info/* 2>/dev/null || true
    echo "  Emptied user trash."
  else
    read -r -p "Empty user trash? [y/N] " resp
    case "$resp" in
      y|Y|yes|YES)
        rm -rf "${TRASH_DIR:?}"/files/* "${TRASH_DIR:?}"/info/* 2>/dev/null || true
        echo "  Emptied user trash."
        ;;
      *)
        echo "  Skipped user trash."
        ;;
    esac
  fi
fi

# 3. Systemd journal
echo ""
if command -v journalctl >/dev/null 2>&1; then
  echo "Systemd Journal:"
  journalctl --disk-usage 2>/dev/null || true
  echo "  (To vacuum logs older than 7 days: sudo journalctl --vacuum-time=7d)"
fi

# 4. Package Manager Cache
echo ""
echo "Package Manager Cache Status:"
if command -v pacman >/dev/null 2>&1; then
  if [[ -d /var/cache/pacman/pkg ]]; then
    PAC_SIZE="$(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f1 || echo "unknown")"
    echo "  Pacman cache size: $PAC_SIZE (/var/cache/pacman/pkg)"
    echo "  Recommended: 'sudo paccache -r' or 'sudo pacman -Sc'"
  fi
fi

if command -v apt-get >/dev/null 2>&1 || command -v apt >/dev/null 2>&1; then
  if [[ -d /var/cache/apt/archives ]]; then
    APT_SIZE="$(du -sh /var/cache/apt/archives 2>/dev/null | cut -f1 || echo "unknown")"
    echo "  APT cache size: $APT_SIZE (/var/cache/apt/archives)"
    echo "  Recommended: 'sudo apt-get clean' or 'sudo apt-get autoclean'"
  fi
fi

if command -v dnf >/dev/null 2>&1; then
  if [[ -d /var/cache/dnf ]]; then
    DNF_SIZE="$(du -sh /var/cache/dnf 2>/dev/null | cut -f1 || echo "unknown")"
    echo "  DNF cache size: $DNF_SIZE (/var/cache/dnf)"
    echo "  Recommended: 'sudo dnf clean all'"
  fi
fi

if command -v zypper >/dev/null 2>&1; then
  if [[ -d /var/cache/zypp ]]; then
    ZYPP_SIZE="$(du -sh /var/cache/zypp 2>/dev/null | cut -f1 || echo "unknown")"
    echo "  Zypper cache size: $ZYPP_SIZE (/var/cache/zypp)"
    echo "  Recommended: 'sudo zypper clean'"
  fi
fi

if command -v apk >/dev/null 2>&1; then
  if [[ -d /var/cache/apk ]]; then
    APK_SIZE="$(du -sh /var/cache/apk 2>/dev/null | cut -f1 || echo "unknown")"
    echo "  APK cache size: $APK_SIZE (/var/cache/apk)"
    echo "  Recommended: 'sudo apk cache clean'"
  fi
fi

echo ""
echo "Cache inspection completed."
