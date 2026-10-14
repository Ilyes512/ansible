#!/usr/bin/env bash

set -euo pipefail

# Loads the key `op run` passed in into an agent, so it never touches the disk.
if [[ -n "${SSH_PRIVATE_KEY:-}" ]]; then
    eval "$(ssh-agent -s)" >/dev/null
    ssh-add -q - <<<"$SSH_PRIVATE_KEY"
    unset SSH_PRIVATE_KEY
fi

# Sourced rather than executed so that exported variables reach the command below.
shopt -s nullglob
for hook in /etc/docker-entrypoint.d/*.sh; do
    # shellcheck source=/dev/null
    source "$hook"
done
shopt -u nullglob

exec "$@"
