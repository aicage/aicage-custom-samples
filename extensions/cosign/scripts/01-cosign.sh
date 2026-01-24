#!/usr/bin/env bash
set -euo pipefail

# Fetch latest tag
LATEST_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest \
  | grep tag_name | cut -d : -f2 | tr -d "v\", ")

echo "cosign latest version: ${LATEST_VERSION}"

if command -v apk >/dev/null 2>&1; then
  # *** Alpine ***
  apk add --no-cache cosign
elif command -v dpkg >/dev/null 2>&1; then
  # *** Debian ***
  curl -LO "https://github.com/sigstore/cosign/releases/latest/download/cosign_${LATEST}_amd64.deb"
  dpkg -i "cosign_${LATEST_VERSION}_amd64.deb"
  rm "cosign_${LATEST_VERSION}_amd64.deb"
elif command -v rpm >/dev/null 2>&1; then
  # *** RedHat/Fedora ***
  curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-${LATEST_VERSION}-1.x86_64.rpm"
  rpm -ivh "cosign-${LATEST_VERSION}-1.x86_64.rpm"
  rm "cosign-${LATEST_VERSION}-1.x86_64.rpm"
fi

echo "cosign version output:"
cosign version