#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE=""
IMAGE_REF=""

# shellcheck source=./scripts/common.sh
source "${ROOT_DIR}/scripts/common.sh"

usage() {
  cat <<'USAGE'
Usage: scripts/test-base.sh --base <name> --image <ref> [-- <bats-args>]
USAGE
  exit 1
}

reduced_base_smoke_test_files() {
  case "${BASE}" in
    minimal)
      cat <<'EOF'
02-gosu.bats
10-c-cpp.bats
20-python.bats
25-node.bats
90-entrypoint-user.bats
91-entrypoint-mounts.bats
92-entrypoint-workspace.bats
EOF
      ;;
    debian-mirror)
      cat <<'EOF'
02-gosu.bats
20-python.bats
25-node.bats
40-docker.bats
90-entrypoint-user.bats
91-entrypoint-mounts.bats
92-entrypoint-workspace.bats
93-entrypoint-docker.bats
EOF
      ;;
  esac
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
    --)
      shift
      break
      ;;
    *)
      usage
      ;;
  esac
done

[[ -n "${BASE}" ]] || die "--base is required"
[[ -n "${IMAGE_REF}" ]] || die "--image is required"

log "Running base smoke tests for '${BASE}'"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

"${ROOT_DIR}/scripts/get-aicage-release-artifact.sh" \
  aicage-image-base \
  "${tmp_dir}" \
  aicage-image-base-smoke-tests.tar.gz

SMOKE_DIR="${tmp_dir}/tests/bases/smoke"
[[ -d "${SMOKE_DIR}" ]] || die "Base smoke test folder missing"
DEFAULT_SUITE_DIR="${SMOKE_DIR}/default"
[[ -d "${DEFAULT_SUITE_DIR}" ]] || die "Smoke suite folder missing: default"

case "${BASE}" in
  minimal | debian-mirror)
    selected_tests_dir="${tmp_dir}/selected-base-tests"
    mkdir -p "${selected_tests_dir}"

    while IFS= read -r test_file; do
      [[ -n "${test_file}" ]] || continue
      [[ -f "${DEFAULT_SUITE_DIR}/${test_file}" ]] || die "Smoke test file missing: ${test_file}"
      ln -s "${DEFAULT_SUITE_DIR}/${test_file}" "${selected_tests_dir}/${test_file}"
    done < <(reduced_base_smoke_test_files)
    bats_target="${selected_tests_dir}"
    ;;
  *)
    bats_target="${DEFAULT_SUITE_DIR}"
    ;;
esac

AICAGE_IMAGE_BASE_IMAGE="${IMAGE_REF}" \
  bats "${bats_target}" "$@"
