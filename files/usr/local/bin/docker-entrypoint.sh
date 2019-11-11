#!/usr/bin/env sh

set -euo pipefail

if [ !  -z "${KUBECONFIG_OVERRIDE:-}" ]; then
    mkdir -p /${HOME:-root}/.kube
    printf "%s" "$KUBECONFIG_OVERRIDE" > ${HOME:-/root}/.kube/config-override
    export KUBECONFIG="${HOME:-/root}/.kube/config-override"
fi

exec "$@"
