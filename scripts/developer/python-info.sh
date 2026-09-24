#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: python-info.sh [options]

Options:
  -h, --help    Show this help message and exit

Description:
  Displays Python 3 version, executable location, active virtual environment
  status, and installed pip packages summary.
EOF
  exit 0
}

for arg in "$@"; do
  case "$arg" in
    -h|--help) show_help ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

echo "=== Python Environment Information ==="

if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3 is not installed."
  exit 0
fi

echo "Python Version : $(python3 --version)"
echo "Executable Path: $(command -v python3)"

if [[ -n "${VIRTUAL_ENV:-}" ]]; then
  echo "Virtualenv     : Active ($VIRTUAL_ENV)"
elif [[ -n "${CONDA_PREFIX:-}" ]]; then
  echo "Conda Env      : Active ($CONDA_PREFIX)"
else
  echo "Virtualenv     : None (System Python)"
fi

echo ""
if command -v pip3 >/dev/null 2>&1 || command -v pip >/dev/null 2>&1; then
  PIP_CMD="pip3"
  command -v pip3 >/dev/null 2>&1 || PIP_CMD="pip"
  pkg_count=$($PIP_CMD list --format=freeze 2>/dev/null | wc -l || echo 0)
  echo "Installed packages ($PIP_CMD): $pkg_count total"
  echo "Top 10 packages:"
  $PIP_CMD list 2>/dev/null | head -n 12 | tail -n +3 | sed 's/^/  /' || true
else
  echo "pip is not installed."
fi
