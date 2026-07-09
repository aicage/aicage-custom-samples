#!/usr/bin/env bash
set -euo pipefail

if command -v apk >/dev/null 2>&1; then
  # *** Alpine ***
  apk add --no-cache skopeo
elif command -v dpkg >/dev/null 2>&1; then
  # *** Debian ***
  apt-get update
  apt-get install -y --no-install-recommends skopeo
  apt-get clean
  rm -rf /var/lib/apt/lists/*
elif command -v rpm >/dev/null 2>&1; then
  # *** RedHat/Fedora ***
  dnf install -y skopeo
  dnf clean all
else
  echo "Unsupported distro" >&2
  exit 1
fi

echo "skopeo version output:"
skopeo --version
