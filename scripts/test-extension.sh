#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SMOKE_DIR="${ROOT_DIR}/tests/extensions/smoke"
EXTENSION=""
IMAGE_REF=""

# shellcheck source=./scripts/common.sh
source "${ROOT_DIR}/scripts/common.sh"

usage() {
  cat <<'USAGE'
Usage: scripts/test-extension.sh --extension <name> --image <ref> [-- <bats-args>]
USAGE
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --extension)
      [[ $# -ge 2 ]] || usage
      EXTENSION="$2"
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

[[ -n "${EXTENSION}" ]] || die "--extension is required"
[[ -n "${IMAGE_REF}" ]] || die "--image is required"
[[ -d "${SMOKE_DIR}/${EXTENSION}" ]] || die "Extension smoke suite folder missing: ${EXTENSION}"

log "Running extension smoke suite '${EXTENSION}'"
AICAGE_EXTENSION_IMAGE="${IMAGE_REF}" \
  bats "${SMOKE_DIR}/shared" "${SMOKE_DIR}/${EXTENSION}" "$@"
