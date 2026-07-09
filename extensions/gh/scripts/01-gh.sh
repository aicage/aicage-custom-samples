#!/usr/bin/env bash
set -euo pipefail

if command -v apk >/dev/null 2>&1; then
  # *** Alpine ***
  apk add --no-cache github-cli
elif command -v dpkg >/dev/null 2>&1; then
  # *** Debian ***
  (type -p wget >/dev/null || (apt update && apt install wget -y)) &&
    install -d -m 755 /etc/apt/keyrings &&
    out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg &&
    tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null <"$out" &&
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
    install -d -m 755 /etc/apt/sources.list.d &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
    apt update &&
    apt install gh -y &&
    apt-get clean &&
    rm -rf /var/lib/apt/lists/*
elif command -v rpm >/dev/null 2>&1; then
  # *** RedHat/Fedora ***
  dnf install -y dnf5-plugins
  dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
  dnf install -y gh --repo gh-cli
  dnf clean all
fi

echo "gh version output:"
gh --version
