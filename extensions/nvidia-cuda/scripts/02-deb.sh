#!/usr/bin/env bash
set -euo pipefail

if ! command -v dpkg >/dev/null 2>&1; then
  exit 0
fi

case "$(dpkg --print-architecture)" in
  amd64)
    CUDA_ARCH=x86_64
    ;;
  *)
    echo "Unsupported architecture for this extension: $(dpkg --print-architecture)" >&2
    echo "The Debian/Ubuntu CUDA repository is currently configured for amd64 only." >&2
    exit 1
    ;;
esac

if [[ ! -r /etc/os-release ]]; then
  echo "Cannot detect the Debian/Ubuntu release: /etc/os-release is missing." >&2
  exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release

os_like=" ${ID_LIKE:-} "

if [[ " ${ID} ${os_like} " == *" ubuntu "* ]]; then
  distro_family=ubuntu
elif [[ " ${ID} ${os_like} " == *" debian "* ]]; then
  distro_family=debian
else
  echo "This image does not identify as Debian- or Ubuntu-like in /etc/os-release." >&2
  exit 1
fi

if [[ -z "${VERSION_ID:-}" ]]; then
  echo "Cannot detect the Debian/Ubuntu-like version from /etc/os-release." >&2
  exit 1
fi

CUDA_DISTRO="${distro_family}${VERSION_ID//./}"

CUDA_KEYRING_VERSION=1.1-1
CUDA_KEYRING_DEB="cuda-keyring_${CUDA_KEYRING_VERSION}_all.deb"
CUDA_KEYRING_URL="https://developer.download.nvidia.com/compute/cuda/repos/${CUDA_DISTRO}/${CUDA_ARCH}/${CUDA_KEYRING_DEB}"

echo "Installing NVIDIA CUDA apt repository from ${CUDA_KEYRING_URL}"

if ! curl -fsI "${CUDA_KEYRING_URL}" >/dev/null; then
  echo "No NVIDIA CUDA apt repo was found for ${distro_family}-like version ${VERSION_ID} (${CUDA_DISTRO}/${CUDA_ARCH})." >&2
  exit 1
fi

apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  gnupg

curl -fsSL "${CUDA_KEYRING_URL}" -o "/tmp/${CUDA_KEYRING_DEB}"
dpkg -i "/tmp/${CUDA_KEYRING_DEB}"
rm -f "/tmp/${CUDA_KEYRING_DEB}"

apt-get update
apt-get install -y --no-install-recommends cuda-toolkit
apt-get clean
rm -rf /var/lib/apt/lists/*

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

if dpkg-query -W -f='${Status}\n' cuda-toolkit 2>/dev/null | grep -q "install ok installed"; then
  echo "Verified package install: cuda-toolkit"
else
  echo "cuda-toolkit was installed, but dpkg-query could not verify package state." >&2
  exit 1
fi

if find /usr/local -type f \( -name 'libcudart.so' -o -name 'libcudart.so.*' \) | grep -q .; then
  echo "Verified CUDA runtime library: libcudart.so"
else
  echo "CUDA runtime library libcudart.so was not found under /usr/local after installation." >&2
  exit 1
fi
