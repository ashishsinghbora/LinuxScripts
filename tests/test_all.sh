#!/usr/bin/env bash

# Test suite for LinuxScripts repository.
# Discovers all *.sh scripts under the repository and performs basic validation:
#   1. Syntax check (bash -n)
#   2. ShellCheck (if available)
#   3. Ensure executable permission
#   4. Run help output (-h) and expect exit status 0 (if script implements it)

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: test_all.sh [options]

Options:
  -h, --help    Show this help message and exit

Description:
  Discovers all utility scripts in the repository, validates syntax (bash -n),
  runs ShellCheck if installed, verifies executable permissions, and tests --help/-h.
EOF
  exit 0
}

# Handle options
while (( "$#" )); do
  case "$1" in
    -h|--help) show_help ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

ROOT_DIR="$(git rev-parse --show-toplevel)"
FAILED=0
SELF="$(realpath "$0")"

while IFS= read -r script; do
    # Skip self to prevent recursive execution
    if [[ "$(realpath "$script")" == "$SELF" ]]; then
        continue
    fi
    echo "Testing $script"
    # 1. Syntax
    if ! bash -n "$script"; then
        echo "  ❌ Syntax error in $script"
        FAILED=$((FAILED+1))
        continue
    fi
    # 2. ShellCheck (optional)
    if command -v shellcheck >/dev/null 2>&1; then
        if ! shellcheck "$script"; then
            echo "  ❌ ShellCheck warnings/errors in $script"
            FAILED=$((FAILED+1))
        fi
    fi
    # 3. Executable permission
    if [[ ! -x "$script" ]]; then
        echo "  ⚠️  Adding executable permission to $script"
        chmod +x "$script"
    fi
    # 4. Help flag test (-h or --help)
    if "$script" -h >/dev/null 2>&1 || "$script" --help >/dev/null 2>&1; then
        echo "  ✅ Help flag works"
    else
        echo "  ❌ Help flag (-h / --help) failed"
        FAILED=$((FAILED+1))
    fi
done < <(find "$ROOT_DIR/scripts" -type f -name "*.sh" | sort)

if [[ $FAILED -eq 0 ]]; then
    echo "All tests passed."
    exit 0
else
    echo "$FAILED test(s) failed."
    exit 1
fi
