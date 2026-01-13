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

LABEL org.opencontainers.image.title="custom aicage-image-base" \
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
    echo "Setup: Downloading os-installer scripts from 'github.com/aicage/aicage-image-base' ..." && \
    mkdir -p "${AICAGE_IMAGE_BASE_DIR}" && \
    curl -fsSL \
      https://github.com/aicage/aicage-image-base/releases/latest/download/os-installers.tar.gz \
      -o "${AICAGE_IMAGE_BASE_DIR}/os-installers.tar.gz" && \
    tar -xzf "${AICAGE_IMAGE_BASE_DIR}/os-installers.tar.gz" -C "${AICAGE_IMAGE_BASE_DIR}" && \
    \
    echo "Setup: Downloading entrypoint.sh from 'github.com/aicage/aicage-image-base' ..." && \
    curl -fsSL \
      https://github.com/aicage/aicage-image-base/releases/latest/download/entrypoint.sh \
      -o "${AICAGE_IMAGE_BASE_DIR}/entrypoint.sh" && \
    chmod +x "${AICAGE_IMAGE_BASE_DIR}/entrypoint.sh" && \
    \
    echo "Install: Running os-installer scripts for distro '${AICAGE_INSTALL_DISTRO}' ..." && \
    "${AICAGE_IMAGE_BASE_DIR}"/os-installers/distro/${AICAGE_INSTALL_DISTRO}/install.sh && \
    \
    echo "Install: Copy aicage entrypoint.sh ..." && \
    cp "${AICAGE_IMAGE_BASE_DIR}"/os-installers/entrypoint.sh /usr/local/bin/entrypoint.sh && \
    \
    echo "Clean up: Remove downloaded files ..." && \
    rm -rf "${AICAGE_IMAGE_BASE_DIR}"

ENV AICAGE_ENTRYPOINT_CMD=bash

# Use tini from PATH to work across distros (e.g. Alpine installs it in /sbin).
ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
