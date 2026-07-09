#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=./scripts/common.sh
source "${ROOT_DIR}/scripts/common.sh"

EXTENSION=""
FROM_IMAGE=""
IMAGE_REF=""
EXPECT_FAILURE=false

usage() {
  cat <<'USAGE'
Usage: scripts/build-extension.sh --extension <name> --from-image <ref> --image <tag> [--expect-failure]
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
    --from-image)
      [[ $# -ge 2 ]] || usage
      FROM_IMAGE="$2"
      shift 2
      ;;
    --image)
      [[ $# -ge 2 ]] || usage
      IMAGE_REF="$2"
      shift 2
      ;;
    --expect-failure)
      EXPECT_FAILURE=true
      shift
      ;;
    -h | --help)
      usage
      ;;
    *)
      usage
      ;;
  esac
done

[[ -n "${EXTENSION}" ]] || die "--extension is required"
[[ -n "${FROM_IMAGE}" ]] || die "--from-image is required"
[[ -n "${IMAGE_REF}" ]] || die "--image is required"
[[ -d "${ROOT_DIR}/extensions/${EXTENSION}/scripts" ]] || die "Unknown extension: ${EXTENSION}"

set +e
DOCKER_BUILDKIT=1 docker build \
  --tag "${IMAGE_REF}" \
  --build-arg "FROM_IMAGE=${FROM_IMAGE}" \
  --file - \
  "${ROOT_DIR}" <<EOF
# check=skip=InvalidDefaultArgInFrom
ARG FROM_IMAGE
FROM \${FROM_IMAGE}

RUN set -eu; \
  if command -v apk >/dev/null 2>&1; then \
    apk add --no-cache bash ca-certificates curl tar unzip xz; \
  elif command -v apt-get >/dev/null 2>&1; then \
    apt-get update && \
    apt-get install -y --no-install-recommends bash ca-certificates curl tar unzip xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*; \
  elif command -v dnf >/dev/null 2>&1; then \
    dnf install -y bash ca-certificates curl tar unzip xz && \
    dnf clean all; \
  else \
    echo "Unsupported distro" >&2; \
    exit 1; \
  fi

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN --mount=type=bind,source=extensions/${EXTENSION}/scripts,target=/tmp/extension,readonly \
    mkdir -p /tmp/extension-run && \
    cp /tmp/extension/*.sh /tmp/extension-run/ && \
    for script in /tmp/extension-run/*.sh; do \
      sed -i 's/\r$//' "\$script"; \
      chmod +x "\$script"; \
      bash "\$script"; \
    done && \
    rm -rf /tmp/extension-run

CMD ["/bin/bash", "-lc", "echo extension-ready"]
EOF
build_status=$?
set -e

if ${EXPECT_FAILURE}; then
  if [[ ${build_status} -eq 0 ]]; then
    die "Extension '${EXTENSION}' unexpectedly built successfully"
  fi
  log "Extension '${EXTENSION}' failed as expected"
else
  [[ ${build_status} -eq 0 ]] || die "Extension '${EXTENSION}' build failed"
fi
