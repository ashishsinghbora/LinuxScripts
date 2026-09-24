#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<'EOF'
Usage: docker-info.sh [options]

Options:
  -h, --help    Show this help message and exit

Description:
  Displays Docker client and server versions, running containers, images,
  and storage driver status.
EOF
  exit 0
}

for arg in "$@"; do
  case "$arg" in
    -h|--help) show_help ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

echo "=== Docker Information ==="
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed on this system."
  exit 0
fi

docker --version

echo ""
if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is either not running or current user does not have permission to access the Docker socket."
  echo "Tip: Check 'systemctl status docker' or ensure user is in the 'docker' group."
  exit 0
fi

echo "Containers:"
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}" | head -n 10

echo ""
echo "Images (first 10):"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | head -n 11
