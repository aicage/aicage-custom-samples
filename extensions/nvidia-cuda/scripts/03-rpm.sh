#!/usr/bin/env bash
set -euo pipefail

if ! command -v rpm >/dev/null 2>&1; then
  exit 0
fi

if ! command -v dnf >/dev/null 2>&1; then
  echo "RPM-based image detected, but this extension currently requires dnf for CUDA installation." >&2
  exit 1
fi

case "$(uname -m)" in
  x86_64)
    CUDA_ARCH=x86_64
    ;;
  *)
    echo "Unsupported architecture for this extension: $(uname -m)" >&2
    echo "The Fedora CUDA repository is currently configured for x86_64 only." >&2
    exit 1
    ;;
esac

if [[ ! -r /etc/os-release ]]; then
  echo "Cannot detect the Fedora release: /etc/os-release is missing." >&2
  exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release

os_like=" ${ID_LIKE:-} "

if [[ " ${ID} ${os_like} " != *" fedora "* ]]; then
  echo "This RPM-based image does not identify as Fedora-like in /etc/os-release." >&2
  exit 1
fi

if [[ -z "${VERSION_ID:-}" ]]; then
  echo "Cannot detect Fedora version from /etc/os-release." >&2
  exit 1
fi

CUDA_DISTRO="fedora${VERSION_ID}"
CUDA_REPO_URL="https://developer.download.nvidia.com/compute/cuda/repos/${CUDA_DISTRO}/${CUDA_ARCH}/cuda-${CUDA_DISTRO}.repo"

echo "Installing NVIDIA CUDA dnf repository from ${CUDA_REPO_URL}"

if ! curl -fsI "${CUDA_REPO_URL}" >/dev/null; then
  echo "No NVIDIA CUDA dnf repo was found for Fedora-like version ${VERSION_ID} (${CUDA_DISTRO}/${CUDA_ARCH})." >&2
  exit 1
fi

dnf install -y dnf-plugins-core ca-certificates curl
dnf config-manager addrepo --from-repofile="${CUDA_REPO_URL}"
dnf clean all
dnf install -y cuda-toolkit
dnf clean all

cuda_bin_dir=""
for candidate in /usr/local/cuda/bin /usr/local/cuda-*/bin; do
  if [[ -x "${candidate}/nvcc" ]]; then
    cuda_bin_dir="${candidate}"
    break
  fi
done

if [[ -z "${cuda_bin_dir}" ]]; then
  echo "CUDA compiler nvcc was not found after installation." >&2
  exit 1
fi

ln -sf "${cuda_bin_dir}/nvcc" /usr/local/bin/nvcc
echo "Exposed CUDA compiler on PATH: nvcc"

mkdir -p /usr/local/share/aicage-extensions
printf '%s\n' "cuda-toolkit" >/usr/local/share/aicage-extensions/nvidia-cuda.txt

if rpm -q cuda-toolkit >/dev/null 2>&1; then
  echo "Verified package install: cuda-toolkit"
else
  echo "cuda-toolkit was installed, but rpm could not verify package state." >&2
  exit 1
fi

if find /usr/local -type f \( -name 'libcudart.so' -o -name 'libcudart.so.*' \) | grep -q .; then
  echo "Verified CUDA runtime library: libcudart.so"
else
  echo "CUDA runtime library libcudart.so was not found under /usr/local after installation." >&2
  exit 1
fi
