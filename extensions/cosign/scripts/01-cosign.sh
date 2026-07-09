#!/usr/bin/env bash
set -euo pipefail

ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64)
    DEB_ARCH=amd64
    RPM_ARCH=x86_64
    ;;
  aarch64)
    DEB_ARCH=arm64
    RPM_ARCH=aarch64
    ;;
  *)
    echo "Unsupported architecture: ${ARCH}" >&2
    exit 1
    ;;
esac

# Fetch latest tag
LATEST_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest |
  grep tag_name | cut -d : -f2 | tr -d "v\", ")

echo "cosign latest version: ${LATEST_VERSION}"

if command -v apk >/dev/null 2>&1; then
  # *** Alpine ***
  apk add --no-cache cosign
elif command -v dpkg >/dev/null 2>&1; then
  # *** Debian ***
  deb_file="cosign_${LATEST_VERSION}_${DEB_ARCH}.deb"
  curl -LO "https://github.com/sigstore/cosign/releases/latest/download/${deb_file}"
  dpkg -i "${deb_file}"
  rm "${deb_file}"
elif command -v rpm >/dev/null 2>&1; then
  # *** RedHat/Fedora ***
  rpm_file="cosign-${LATEST_VERSION}-1.${RPM_ARCH}.rpm"
  curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/${rpm_file}"
  rpm -ivh "${rpm_file}"
  rm "${rpm_file}"
fi

echo "cosign version output:"
cosign version
