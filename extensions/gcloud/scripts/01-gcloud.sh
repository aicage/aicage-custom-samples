#!/usr/bin/env bash
set -euo pipefail

GCLOUD_INSTALL_DIR="${GCLOUD_INSTALL_DIR:-/opt/google-cloud-sdk}"

install_from_archive() {
  local arch archive_name tmp_dir

  command -v curl >/dev/null 2>&1 || {
    echo "curl is required" >&2
    exit 1
  }
  command -v tar >/dev/null 2>&1 || {
    echo "tar is required" >&2
    exit 1
  }
  command -v python3 >/dev/null 2>&1 || {
    echo "python3 is required" >&2
    exit 1
  }

  arch="$(uname -m)"
  case "${arch}" in
    x86_64)
      archive_name="google-cloud-cli-linux-x86_64.tar.gz"
      ;;
    aarch64 | arm64)
      archive_name="google-cloud-cli-linux-arm.tar.gz"
      ;;
    x86 | i386 | i686)
      archive_name="google-cloud-cli-linux-x86.tar.gz"
      ;;
    *)
      echo "Unsupported architecture for Google Cloud CLI archive install: ${arch}" >&2
      exit 1
      ;;
  esac

  tmp_dir="$(mktemp -d)"

  curl -fsSL \
    "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${archive_name}" \
    -o "${tmp_dir}/${archive_name}"

  tar -xzf "${tmp_dir}/${archive_name}" -C "${tmp_dir}"
  rm -rf "${GCLOUD_INSTALL_DIR}"
  mkdir -p "$(dirname "${GCLOUD_INSTALL_DIR}")"
  mv "${tmp_dir}/google-cloud-sdk" "${GCLOUD_INSTALL_DIR}"

  "${GCLOUD_INSTALL_DIR}/install.sh" \
    --quiet \
    --path-update=false \
    --bash-completion=false \
    --rc-path=/dev/null \
    --usage-reporting=false

  ln -sf "${GCLOUD_INSTALL_DIR}/bin/gcloud" /usr/local/bin/gcloud
  ln -sf "${GCLOUD_INSTALL_DIR}/bin/gsutil" /usr/local/bin/gsutil
  ln -sf "${GCLOUD_INSTALL_DIR}/bin/bq" /usr/local/bin/bq
  rm -rf "${tmp_dir}"
}

install_from_deb_repo() {
  command -v curl >/dev/null 2>&1 || {
    echo "curl is required" >&2
    exit 1
  }
  command -v gpg >/dev/null 2>&1 || {
    echo "gpg is required for Debian/Ubuntu installs" >&2
    exit 1
  }

  install -d -m 755 /usr/share/keyrings /etc/apt/sources.list.d
  curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg |
    gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
  printf '%s\n' \
    "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    >/etc/apt/sources.list.d/google-cloud-sdk.list

  apt-get update
  CLOUDSDK_SKIP_PY_COMPILATION=1 apt-get install -y --no-install-recommends google-cloud-cli
  apt-get clean
  rm -rf /var/cache/apt/archives/*
  rm -rf /var/lib/apt/lists/*
}

install_from_rpm_repo() {
  local arch baseurl gpgkey major package_name

  arch="$(uname -m)"
  case "${arch}" in
    x86_64 | aarch64)
      ;;
    *)
      echo "Unsupported architecture for Google Cloud CLI RPM install: ${arch}" >&2
      exit 1
      ;;
  esac

  major=9
  if [[ -r /etc/os-release ]]; then
    # RHEL-compatible images use VERSION_ID to distinguish el9 vs el10 repo config.
    # Google documents both; defaulting to el9 when unavailable is a conservative fallback.
    # shellcheck disable=SC1091
    . /etc/os-release
    if [[ -n "${VERSION_ID:-}" ]]; then
      major="${VERSION_ID%%.*}"
    fi
  fi

  if [[ "${major}" =~ ^[0-9]+$ ]] && ((major >= 10)); then
    baseurl="https://packages.cloud.google.com/yum/repos/cloud-sdk-el10-${arch}"
    gpgkey="https://packages.cloud.google.com/yum/doc/rpm-package-key-v10.gpg"
  else
    baseurl="https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-${arch}"
    gpgkey="https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg"
  fi

  cat >/etc/yum.repos.d/google-cloud-sdk.repo <<EOF
[google-cloud-cli]
name=Google Cloud CLI
baseurl=${baseurl}
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=${gpgkey}
EOF

  package_name="libxcrypt-compat"
  if [[ "${arch}" == "x86_64" ]]; then
    package_name="libxcrypt-compat.x86_64"
  fi

  dnf install -y "${package_name}"
  CLOUDSDK_SKIP_PY_COMPILATION=1 dnf install -y google-cloud-cli
  dnf clean all
  rm -rf /var/cache/dnf/*
}

if command -v apk >/dev/null 2>&1; then
  # *** Alpine / generic Linux archive install ***
  install_from_archive
elif command -v dpkg >/dev/null 2>&1; then
  # *** Debian/Ubuntu ***
  install_from_deb_repo
elif command -v rpm >/dev/null 2>&1; then
  # *** RedHat/Fedora/CentOS ***
  install_from_rpm_repo
else
  # *** Generic Linux ***
  install_from_archive
fi

echo "gcloud version output:"
gcloud --version
