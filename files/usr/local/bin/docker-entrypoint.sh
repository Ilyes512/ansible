#!/usr/bin/env sh

set -euo pipefail

if [ !  -z "${KUBECONFIG_OVERRIDE:-}" ]; then
    mkdir -p /root/.kube
    printf "%s" "${KUBECONFIG_OVERRIDE}" > /root/.kube/config-override
    export KUBECONFIG="/root/.kube/config-override"
fi

exec "$@"
