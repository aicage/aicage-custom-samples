#!/usr/bin/env bash
set -euo pipefail

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ARCH=amd64 ;;
  aarch64) ARCH=arm64 ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

curl -fsSL \
  "https://github.com/regclient/regclient/releases/latest/download/regctl-linux-${ARCH}" \
  -o /usr/local/bin/regctl

chmod 755 /usr/local/bin/regctl

echo "regctl version output:"
regctl version
