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
  bundle_file="${rpm_file}.sigstore.json"
  release_url="https://github.com/sigstore/cosign/releases/download/v${LATEST_VERSION}"

  curl -fLO "${release_url}/${rpm_file}"
  curl -fLO "${release_url}/${bundle_file}"

  # Cosign's RPM lacks an embedded OpenPGP signature but has an external
  # keyless Sigstore bundle. Fedora 45+ rejects the RPM when installed directly,
  # so verify that bundle before bypassing RPM's OpenPGP signature check.
  verifier_file="cosign-linux-${DEB_ARCH}"
  curl -fLO "${release_url}/${verifier_file}"
  chmod +x "${verifier_file}"
  "./${verifier_file}" verify-blob \
    --bundle "${bundle_file}" \
    --certificate-identity "keyless@projectsigstore.iam.gserviceaccount.com" \
    --certificate-oidc-issuer "https://accounts.google.com" \
    "${rpm_file}"
  rpm -ivh --nosignature "${rpm_file}"
  rm "${rpm_file}" "${bundle_file}" "${verifier_file}"
elif command -v pacman >/dev/null 2>&1; then
  # *** Arch ***
  pacman -Sy --noconfirm cosign
  pacman -Scc --noconfirm
else
  echo "Unsupported distro" >&2
  exit 1
fi

echo "cosign version output:"
cosign version
