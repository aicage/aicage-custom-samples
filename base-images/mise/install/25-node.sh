#!/usr/bin/env bash
set -euo pipefail

# xdg-utils: provides xdg-open; required by npm-installed CLI agents to open
# auth/docs URLs.
apk add --no-cache xdg-utils

mise use -g node@lts

export PATH="/root/.local/share/mise/shims:${PATH}"

npm config set prefix /usr/local

npm install -g corepack
corepack enable
