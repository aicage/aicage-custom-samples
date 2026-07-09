#!/usr/bin/env bash
set -euo pipefail

if command -v mise >/dev/null 2>&1; then
  exit 0
fi

export MISE_INSTALL_PATH=/usr/local/bin/mise
curl https://mise.run | sh

cat > /etc/profile.d/mise.sh <<'EOF'
export PATH="$HOME/.local/share/mise/shims:$PATH"
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi
EOF
