#!/usr/bin/env sh
set -eu

workspace="${AICAGE_WORKSPACE:-/workspace}"

test -d /proc
test -d "${workspace}"
test -r /proc/loadavg
test -x /usr/local/bin/aicage-monitor
test -x /usr/local/bin/entrypoint.sh
