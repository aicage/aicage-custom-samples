#!/usr/bin/env bash
set -euo pipefail

apk add --no-cache \
  bash \
  curl \
  htop \
  iproute2 \
  libc-utils \
  git \
  lsof \
  patch \
  procps \
  shadow \
  sysstat \
  tini \
  tzdata
