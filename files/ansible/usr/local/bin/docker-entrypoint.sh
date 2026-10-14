#!/usr/bin/env bash

set -euo pipefail

# Sourced rather than executed so that exported variables reach the command below.
shopt -s nullglob
for hook in /etc/docker-entrypoint.d/*.sh; do
    # shellcheck source=/dev/null
    source "$hook"
done
shopt -u nullglob

exec "$@"
