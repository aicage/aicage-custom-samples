# check=skip=InvalidDefaultArgInFrom
ARG FROM_IMAGE

FROM ${FROM_IMAGE} AS from_image

LABEL org.opencontainers.image.title="aicage-image-base" \
      org.opencontainers.image.description="Prebuilt base layer for agent images" \
      org.opencontainers.image.source="https://github.com/aicage/aicage-image-base" \
      org.opencontainers.image.licenses="Apache-2.0"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    AICAGE_USER=aicage \
    AICAGE_UID=1000 \
    AICAGE_GID=1000 \
    AICAGE_WORKSPACE=/workspace \
    PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/opt/pipx/bin \
    PATH="/opt/pipx/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin" \
    NPM_CONFIG_PREFIX=/usr/local

RUN --mount=type=bind,source=install.sh,target=/tmp/aicage/install.sh,readonly \
     --mount=type=bind,source=install,target=/tmp/aicage/install,readonly \
    /tmp/aicage/install.sh

# Copy aicage entrypoint.sh
RUN curl -fsSL \
      https://github.com/aicage/aicage-image-base/releases/latest/download/entrypoint.sh \
      -o /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

ENV AICAGE_ENTRYPOINT_CMD=bash

# Use tini from PATH to work across distros (e.g. Alpine installs it in /sbin).
ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
