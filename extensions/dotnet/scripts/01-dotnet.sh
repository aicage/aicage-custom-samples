#!/usr/bin/env bash
set -euo pipefail

DOTNET_CHANNEL="${DOTNET_CHANNEL:-8.0}"
DOTNET_INSTALL_DIR="${DOTNET_INSTALL_DIR:-/usr/share/dotnet}"

ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64)
    DOTNET_ARCH="x64"
    ;;
  aarch64)
    DOTNET_ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: ${ARCH}" >&2
    exit 1
    ;;
esac

if command -v apk >/dev/null 2>&1; then
  # *** Alpine ***
  apk add --no-cache \
    bash \
    curl \
    icu-data-full \
    icu-libs \
    libgcc \
    libstdc++ \
    zlib
elif command -v dpkg >/dev/null 2>&1; then
  # *** Debian ***
  apt-get update
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    icu-devtools \
    libgcc-s1 \
    libicu-dev \
    libssl3 \
    libstdc++6 \
    zlib1g
  apt-get clean
  rm -rf /var/lib/apt/lists/*
elif command -v rpm >/dev/null 2>&1; then
  # *** RedHat/Fedora ***
  dnf install -y \
    ca-certificates \
    curl \
    icu \
    libgcc \
    libstdc++ \
    openssl-libs \
    openssl3-libs \
    zlib
  dnf clean all
elif command -v pacman >/dev/null 2>&1; then
  # *** Arch ***
  pacman -Sy --noconfirm \
    bash \
    ca-certificates \
    curl \
    gcc-libs \
    icu \
    krb5 \
    libunwind \
    openssl \
    zlib
  pacman -Scc --noconfirm
else
  echo "Unsupported distro" >&2
  exit 1
fi

mkdir -p "${DOTNET_INSTALL_DIR}"

tmp_dir="$(mktemp -d)"

curl -fsSL https://dot.net/v1/dotnet-install.sh -o "${tmp_dir}/dotnet-install.sh"
chmod +x "${tmp_dir}/dotnet-install.sh"

"${tmp_dir}/dotnet-install.sh" \
  --channel "${DOTNET_CHANNEL}" \
  --architecture "${DOTNET_ARCH}" \
  --install-dir "${DOTNET_INSTALL_DIR}"

ln -sf "${DOTNET_INSTALL_DIR}/dotnet" /usr/local/bin/dotnet
rm -rf "${tmp_dir}"

echo "dotnet version output:"
dotnet --version
echo "dotnet info output:"
dotnet --info
