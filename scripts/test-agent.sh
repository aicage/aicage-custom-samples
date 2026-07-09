#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT=""
IMAGE_REF=""

# shellcheck source=./scripts/common.sh
source "${ROOT_DIR}/scripts/common.sh"

usage() {
  cat <<'USAGE'
Usage: scripts/test-agent.sh --agent <name> --image <ref> [-- <bats-args>]
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
    --image)
      [[ $# -ge 2 ]] || usage
      IMAGE_REF="$2"
      shift 2
      ;;
    -h | --help)
      usage
      ;;
    --)
      shift
      break
      ;;
    *)
      usage
      ;;
  esac
done

[[ -n "${AGENT}" ]] || die "--agent is required"
[[ -n "${IMAGE_REF}" ]] || die "--image is required"

log "Running agent smoke suite '${AGENT}'"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

"${ROOT_DIR}/scripts/get-aicage-release-artifact.sh" \
  aicage-image \
  "${tmp_dir}" \
  aicage-image-smoke-tests.tar.gz

SMOKE_DIR="${tmp_dir}/tests/agents/smoke"
[[ -d "${SMOKE_DIR}" ]] || die "Agent smoke test folder missing"

ln -s "${ROOT_DIR}/agents" "${tmp_dir}/agents"

AICAGE_IMAGE="${IMAGE_REF}" \
  AGENT="${AGENT}" \
  bats "${SMOKE_DIR}" "$@"
