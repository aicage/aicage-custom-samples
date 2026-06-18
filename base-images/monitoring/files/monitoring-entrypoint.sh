#!/usr/bin/env bash
set -euo pipefail

if [[ "${AICAGE_ENABLE_HERAKLES:-1}" != "0" ]]; then
  /usr/local/bin/herakles-node-exporter \
    --config /etc/herakles/node-exporter.yaml \
    > /tmp/herakles-node-exporter.log 2>&1 &
fi

exec /usr/local/bin/entrypoint.sh
