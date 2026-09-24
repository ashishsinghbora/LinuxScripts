#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: dev-environment-info.sh [options]

Options:
  -h, --help    Show this help message and exit

Description:
  Inspects the system and reports detected programming languages, compilers,
  runtimes, package managers, and developer tools.
EOF
  exit 0
}

for arg in "$@"; do
  case "$arg" in
    -h|--help) show_help ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

echo "=== Developer Environment Summary ==="

check_tool() {
  local name="$1"
  local cmd="$2"
  local ver_flag="${3:---version}"

  printf "%-18s: " "$name"
  if command -v "$cmd" >/dev/null 2>&1; then
    local ver
    ver=$("$cmd" "$ver_flag" 2>&1 | head -n 1 || echo "installed")
    echo "$ver ($cmd)"
  else
    echo "Not installed"
  fi
}

echo "[Core SCM & Build]"
check_tool "Git" "git" "--version"
check_tool "Make" "make" "--version"
check_tool "CMake" "cmake" "--version"
check_tool "GCC" "gcc" "--version"
check_tool "Clang" "clang" "--version"

echo ""
echo "[Runtimes & Interpreters]"
check_tool "Python 3" "python3" "--version"
check_tool "Node.js" "node" "--version"
check_tool "Go" "go" "version"
check_tool "Rust (rustc)" "rustc" "--version"
check_tool "Java" "java" "-version"

echo ""
echo "[Containers & Cloud]"
check_tool "Docker" "docker" "--version"
check_tool "Podman" "podman" "--version"
check_tool "Kubectl" "kubectl" "version --client"
