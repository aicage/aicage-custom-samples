#!/usr/bin/env bash
set -euo pipefail

GHCUP_PREFIX="${GHCUP_PREFIX:-/opt}"
GHCUP_BIN="${GHCUP_PREFIX}/.ghcup/bin"

for command_name in curl gcc make perl tar xz; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "Haskell extension requires '${command_name}'." >&2
    exit 1
  fi
done

tmp_home="$(mktemp -d)"
tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "${tmp_home}" "${tmp_dir}"
}
trap cleanup EXIT

curl \
  -fsSL \
  --retry 8 \
  --retry-all-errors \
  --retry-delay 2 \
  --max-time 300 \
  https://get-ghcup.haskell.org \
  -o "${tmp_dir}/bootstrap-haskell.sh"

HOME="${tmp_home}" \
  GHCUP_INSTALL_BASE_PREFIX="${GHCUP_PREFIX}" \
  BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
  BOOTSTRAP_HASKELL_INSTALL_HLS=1 \
  BOOTSTRAP_HASKELL_INSTALL_NO_STACK_HOOK=1 \
  BOOTSTRAP_HASKELL_GHC_VERSION="${BOOTSTRAP_HASKELL_GHC_VERSION:-recommended}" \
  BOOTSTRAP_HASKELL_CABAL_VERSION="${BOOTSTRAP_HASKELL_CABAL_VERSION:-recommended}" \
  BOOTSTRAP_HASKELL_HLS_VERSION="${BOOTSTRAP_HASKELL_HLS_VERSION:-recommended}" \
  BOOTSTRAP_HASKELL_STACK_VERSION="${BOOTSTRAP_HASKELL_STACK_VERSION:-recommended}" \
  sh "${tmp_dir}/bootstrap-haskell.sh"

install -d /usr/local/bin /etc/profile.d
for binary in ghcup ghc ghci runghc runhaskell cabal stack haskell-language-server-wrapper haskell-language-server; do
  if [[ -x "${GHCUP_BIN}/${binary}" ]]; then
    ln -sfn "${GHCUP_BIN}/${binary}" "/usr/local/bin/${binary}"
  fi
done

cat >/etc/profile.d/haskell.sh <<EOF
export GHCUP_INSTALL_BASE_PREFIX=${GHCUP_PREFIX}
export PATH=${GHCUP_BIN}:\$PATH
EOF

rm -rf /root/.cabal /root/.cache/ghcup /root/.ghcup /root/.stack

echo "ghc version output:"
ghc --version
echo "cabal version output:"
cabal --version
echo "stack version output:"
stack --version
