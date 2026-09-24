#!/usr/bin/env bash

set -euo pipefail

echo "Disk usage:"
echo

df -hT --exclude-type=tmpfs --exclude-type=devtmpfs
