#!/usr/bin/env bash

set -euo pipefail

if command -v pacman >/dev/null 2>&1; then
    echo "Detected Arch Linux"
    sudo pacman -Syu

elif command -v apt >/dev/null 2>&1; then
    echo "Detected Debian/Ubuntu"
    sudo apt update
    sudo apt upgrade

elif command -v dnf >/dev/null 2>&1; then
    echo "Detected Fedora/RHEL"
    sudo dnf upgrade

elif command -v zypper >/dev/null 2>&1; then
    echo "Detected openSUSE"
    sudo zypper update

else
    echo "Unsupported package manager."
    exit 1
fi
