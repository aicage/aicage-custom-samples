#!/usr/bin/env bash
set -euo pipefail

curl \
  -fsSL \
  --retry 8 \
  --retry-all-errors \
  --retry-delay 2 \
  --max-time 300 \
  https://code.kimi.com/install.sh |
  UV_PYTHON_INSTALL_DIR=/opt/uv/python \
    UV_TOOL_DIR=/opt/uv/tools \
    UV_TOOL_BIN_DIR=/usr/local/bin \
    bash

install -d /usr/share/licenses/kimi

for file in LICENSE NOTICE; do
  curl \
    -fsSL \
    --retry 8 \
    --retry-all-errors \
    --retry-delay 2 \
    --max-time 300 \
    https://raw.githubusercontent.com/MoonshotAI/kimi-cli/refs/heads/main/"${file}" \
    -o /usr/share/licenses/kimi/"${file}"
done

# Add LICENSE for codex, see NOTICE file of kimi
install -d /usr/share/licenses/codex
curl \
  -fsSL \
  --retry 8 \
  --retry-all-errors \
  --retry-delay 2 \
  --max-time 300 \
  https://raw.githubusercontent.com/openai/codex/main/LICENSE \
  -o /usr/share/licenses/codex/LICENSE
