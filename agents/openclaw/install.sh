#!/usr/bin/env bash
set -euo pipefail

npm install -g openclaw@latest --allow-scripts=openclaw

install -d /usr/share/licenses/openclaw
curl \
  -fsSL \
  --retry 8 \
  --retry-all-errors \
  --retry-delay 2 \
  --max-time 300 \
  https://raw.githubusercontent.com/openclaw/openclaw/main/LICENSE \
  -o /usr/share/licenses/openclaw/LICENSE
