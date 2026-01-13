#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"

cd "${REPO_ROOT}"

if [[ -d .venv ]]; then
  source .venv/bin/activate

  if [[ ! -f .venv/bin/pymarkdown ]]; then
    echo "Install lint deps"
    pip install -r requirements-dev.txt
  fi
fi

echo "Validate agent.yml files with schema"
check-jsonschema \
  --schemafile validation/agent.schema.json \
  agents/*/agent.yaml

echo "Validate base.yml files with schema"
check-jsonschema \
  --schemafile validation/base.schema.json \
  base-images/*/base.yml

echo "Validate base.yml files with schema"
check-jsonschema \
  --schemafile validation/extension.schema.json \
  extensions/*/extension.yml

echo "Run  yamllint"
yamllint .

echo "Validate Markdown"
pymarkdown --config .pymarkdown.json scan --recurse --exclude './.venv/' .