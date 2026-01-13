#!/usr/bin/env bash
set -euo pipefail

apk add --no-cache \
  py3-pip \
  python3 \
  py3-virtualenv \
  python3-dev

script_dir="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"

"${script_dir}"/generic/install_python.sh
