#!/usr/bin/env bash
set -euo pipefail

if ! command -v go >/dev/null 2>&1; then
  echo "Go is required for the crane extension but was not found on PATH." >&2
  exit 1
fi

export GOBIN=/usr/local/bin
mkdir -p "${GOBIN}"

echo "Installing crane with go"
go install github.com/google/go-containerregistry/cmd/crane@latest

echo "crane version output:"
crane version
