# check=skip=InvalidDefaultArgInFrom

# ## Installation equals to aicage builtin base-images ##
#
# Download os-installer scripts from `aicage-image-base` and install what the builtin base-image 'act' does
#
# Simply set this variable below to match a folder in:
# https://github.com/aicage/aicage-image-base/blob/9b51c14f6d27e6a9012be7be102ba9a6e54558a2/scripts/os-installers/distro

ARG AICAGE_INSTALL_DISTRO=debian

ARG FROM_IMAGE

FROM ${FROM_IMAGE} AS from_image

ARG AICAGE_INSTALL_DISTRO

LABEL org.opencontainers.image.title="Custom aicage-image-base" \
      org.opencontainers.image.description="Locally built base layer for agent images" \
      org.opencontainers.image.source="https://github.com/aicage/aicage-custom-samples" \
      org.opencontainers.image.licenses="Apache-2.0"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    AICAGE_USER=aicage \
    AICAGE_UID=1000 \
    AICAGE_GID=1000 \
    AICAGE_WORKSPACE=/workspace \
    NPM_CONFIG_PREFIX=/usr/local \
    PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/opt/pipx/bin \
    PATH="/opt/pipx/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

USER root

ARG AICAGE_IMAGE_BASE_DIR=/tmp/aicage-image-base

RUN echo "Setup: Install prerequisites ..." && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      tar && \
    \
    mkdir -p "${AICAGE_IMAGE_BASE_DIR}" && \
    cd "${AICAGE_IMAGE_BASE_DIR}" && \
    \
    echo "Setup: Install cosign ..." && \
    arch=$(uname -m | sed 's/x86_64/amd64/; s/aarch64/arm64/') && \
    curl -fsSLo cosign "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-${arch}" && \
    install -m 0755 cosign /usr/local/bin/cosign && \
    rm cosign && \
    \
    echo "Setup: Downloading installation scripts from 'github.com/aicage/aicage-image-base' ..." && \
    for artifact in aicage-image-base.tar.gz SHA256SUMS SHA256SUMS.sigstore.json; do \
      curl -fsSLO https://github.com/aicage/aicage-image-base/releases/latest/download/${artifact}; \
    done && \
    \
    echo "Setup: Verifying signature and checksums ..." && \
    cosign verify-blob \
      --bundle SHA256SUMS.sigstore.json \
      --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
      --certificate-identity-regexp '^https://github\.com/aicage/aicage-image-base/\.github/workflows/release\.yml@refs/tags/.*$' \
      SHA256SUMS && \
    sha256sum -c SHA256SUMS && \
    \
    echo "Setup: Unpacking ..." && \
    tar -xzf aicage-image-base.tar.gz && \
    \
    echo "Install: Running os-installer scripts for distro '${AICAGE_INSTALL_DISTRO}' ..." && \
    "${AICAGE_IMAGE_BASE_DIR}"/os-installers/distro/${AICAGE_INSTALL_DISTRO}/install.sh && \
    \
    echo "Install: Copy aicage entrypoint.sh ..." && \
    cp "${AICAGE_IMAGE_BASE_DIR}"/os-installers/entrypoint.sh /usr/local/bin/entrypoint.sh && \
    \
    echo "Clean up: Remove downloaded files ..." && \
    cd && rm -rf "${AICAGE_IMAGE_BASE_DIR}"

ENV AICAGE_ENTRYPOINT_CMD=bash

# Use tini from PATH to work across distros (e.g. Alpine installs it in /sbin).
ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
