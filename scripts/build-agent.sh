#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=./scripts/common.sh
source "${ROOT_DIR}/scripts/common.sh"

AGENT=""
BASE_IMAGE=""
IMAGE_REF=""

usage() {
  cat <<'USAGE'
Usage: scripts/build-agent.sh --agent <name> --base-image <ref> --image <tag>
USAGE
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      [[ $# -ge 2 ]] || usage
      AGENT="$2"
      shift 2
      ;;
    --base-image)
      [[ $# -ge 2 ]] || usage
      BASE_IMAGE="$2"
      shift 2
      ;;
    --image)
      [[ $# -ge 2 ]] || usage
      IMAGE_REF="$2"
      shift 2
      ;;
    -h | --help)
      usage
      ;;
    *)
      usage
      ;;
  esac
done

[[ -n "${AGENT}" ]] || die "--agent is required"
[[ -n "${BASE_IMAGE}" ]] || die "--base-image is required"
[[ -n "${IMAGE_REF}" ]] || die "--image is required"
[[ -d "${ROOT_DIR}/agents/${AGENT}" ]] || die "Unknown agent: ${AGENT}"

DOCKER_BUILDKIT=1 docker build \
  --tag "${IMAGE_REF}" \
  --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
  --build-arg "AGENT=${AGENT}" \
  --file - \
  "${ROOT_DIR}" <<'EOF'
# check=skip=InvalidDefaultArgInFrom
ARG BASE_IMAGE
ARG AGENT

FROM ${BASE_IMAGE}

ARG AGENT

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN --mount=type=bind,source=agents/,target=/tmp/agents,readonly \
    mkdir -p /tmp/agents-run/${AGENT} && \
    cp -R /tmp/agents/${AGENT}/. /tmp/agents-run/${AGENT}/ && \
    for script in /tmp/agents-run/${AGENT}/*.sh; do \
      sed -i 's/\r$//' "$script"; \
      chmod +x "$script"; \
    done && \
    /tmp/agents-run/${AGENT}/install.sh && \
    rm -rf /tmp/agents-run

ENV AGENT=${AGENT}
ENV AICAGE_ENTRYPOINT_CMD=${AGENT}
EOF
