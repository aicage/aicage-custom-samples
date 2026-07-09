#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=./scripts/common.sh
source "${ROOT_DIR}/scripts/common.sh"

BASE=""
IMAGE_REF=""

usage() {
  cat <<'USAGE'
Usage: scripts/build-base.sh --base <name> --image <tag>
USAGE
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base)
      [[ $# -ge 2 ]] || usage
      BASE="$2"
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

[[ -n "${BASE}" ]] || die "--base is required"
[[ -n "${IMAGE_REF}" ]] || die "--image is required"
[[ -d "${ROOT_DIR}/base-images/${BASE}" ]] || die "Unknown base image: ${BASE}"

FROM_IMAGE="$(base_from_image "${BASE}")"
[[ -n "${FROM_IMAGE}" ]] || die "Could not determine from_image for ${BASE}"

log "Building base image ${BASE} from ${FROM_IMAGE}"
DOCKER_BUILDKIT=1 docker build \
  --tag "${IMAGE_REF}" \
  --build-arg "FROM_IMAGE=${FROM_IMAGE}" \
  "${ROOT_DIR}/base-images/${BASE}"
