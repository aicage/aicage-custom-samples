# check=skip=InvalidDefaultArgInFrom

# ## Installation equals to aicage builtin base-images ##
#
# Download os-installer scripts from `aicage-image-base` and run all of them
#
# Simply set this variable below to match a folder in:
# https://github.com/aicage/aicage-image-base/tree/main/scripts/os-installers/distro

ARG AICAGE_INSTALL_DISTRO=redhat

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
    AICAGE_UID=1000 \
    AICAGE_GID=1000 \
    NPM_CONFIG_PREFIX=/usr/local \
    PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/opt/pipx/bin \
    PATH="/opt/pipx/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

USER root

ARG AICAGE_IMAGE_BASE_DIR=/tmp/aicage-image-base

RUN --mount=type=bind,source=helpers,target=/tmp/aicage/helpers,readonly \
    mkdir -p /tmp/aicage/helpers-run && \
    cp /tmp/aicage/helpers/*.sh /tmp/aicage/helpers-run/ && \
    for script in /tmp/aicage/helpers-run/*.sh; do \
      sed -i 's/\r$//' "$script"; \
      chmod +x "$script"; \
    done && \
    echo "Setup: Install prerequisites ..." && \
    dnf -y makecache && \
    dnf -y install -y \
      curl \
      tar && \
    \
    echo "Setup: Downloading installation scripts from 'github.com/aicage/aicage-image-base' ..." && \
    /tmp/aicage/helpers-run/install-cosign.sh && \
    /tmp/aicage/helpers-run/get-aicage-release-artifact.sh aicage-image-base "${AICAGE_IMAGE_BASE_DIR}" && \
    \
    echo "Install: Running os-installer scripts for distro '${AICAGE_INSTALL_DISTRO}' ..." && \
    "${AICAGE_IMAGE_BASE_DIR}/os-installers/distro/${AICAGE_INSTALL_DISTRO}/install.sh" && \
    \
    echo "Install: Copy aicage entrypoint.sh ..." && \
    cp "${AICAGE_IMAGE_BASE_DIR}"/entrypoint.sh /usr/local/bin/entrypoint.sh && \
    \
    echo "Clean up: Remove downloaded files ..." && \
    rm -rf "${AICAGE_IMAGE_BASE_DIR}" && \
    rm -rv /tmp/aicage/helpers-run

ENV AICAGE_ENTRYPOINT_CMD=bash

# Use tini from PATH to work across distros (e.g. Alpine installs it in /sbin).
ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]

ARG HERAKLES_VERSION=v0.1

RUN set -eux && \
    dnf -y makecache && \
    export HERAKLES_BASE_URL="https://github.com/herakles-now/herakles-node-exporter/releases/download/${HERAKLES_VERSION}" && \
    cd /tmp && \
    curl -fsSLO "${HERAKLES_BASE_URL}/herakles-node-exporter-${HERAKLES_VERSION}-x86_64-linux.tar.gz" && \
    curl -fsSLO "${HERAKLES_BASE_URL}/herakles-node-exporter-${HERAKLES_VERSION}-x86_64-linux.tar.gz.sha256" && \
    sha256sum -c "herakles-node-exporter-${HERAKLES_VERSION}-x86_64-linux.tar.gz.sha256" && \
    tar -xzf "herakles-node-exporter-${HERAKLES_VERSION}-x86_64-linux.tar.gz" && \
    install -m 0755 /tmp/herakles-node-exporter /usr/local/bin/herakles-node-exporter

RUN --mount=type=bind,source=files,target=/tmp/aicage/files,readonly \
    install -d /etc/herakles && \
    install -m 0644 /tmp/aicage/files/node-exporter.yaml /etc/herakles/node-exporter.yaml && \
    install -m 0755 /tmp/aicage/files/monitoring-entrypoint.sh /usr/local/bin/monitoring-entrypoint.sh

# Clean up apt and installation scripts from aicage-image-base
RUN dnf clean all && \
    rm -rf /tmp/aicage/helpers-run /tmp/herakles-node-exporter*

EXPOSE 9215

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD ["wget", "-q", "-O", "/dev/null", "http://localhost:9215/health"]

# Use tini and a monitoring wrapper that starts Herakles before the normal aicage entrypoint.
ENTRYPOINT ["tini", "--", "/usr/local/bin/monitoring-entrypoint.sh"]
