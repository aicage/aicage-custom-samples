#!/usr/bin/env bats

@test "haskell toolchain present" {
  run docker run --rm \
    --entrypoint /bin/bash \
    "${AICAGE_EXTENSION_IMAGE}" \
    -lc 'command -v ghc && ghc --version && command -v cabal && cabal --version && command -v stack && stack --version && command -v haskell-language-server-wrapper'
  [ "$status" -eq 0 ]
}
