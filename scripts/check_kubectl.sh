#!/usr/bin/env bash

set -euo pipefail

printinfo() { printf "\033[1;33m[i]\033[0m %b" "$1\n"; }
printwarn() { printf "\033[1;31m[!]\033[0m %b" "$1\n"; }
printquestion() { printf "\033[1;32m[?]\033[0m %b" "$1\n"; }
printsuccess() { printf "\033[1;32m[✔]\033[0m %b" "$1\n"; }

DOCKER_ARG_VERSION="KUBECTL_VERSION"
DOCKER_ARG_CHECKSUM="KUBECTL_SHA256"
NAME="kubectl"

LATEST_VERSION=$(curl -fsSL "https://storage.googleapis.com/kubernetes-release/release/stable.txt")
LATEST_CHECKSUM=$(curl -fsSl "https://storage.googleapis.com/kubernetes-release/release/$LATEST_VERSION/bin/linux/amd64/kubectl.sha256")

CURRENT_VERSION=$(cat Dockerfile | sed -n "s/^ARG\s*${DOCKER_ARG_VERSION}\s*=\s*\(\S*\).*$/\1/p")
CURRENT_CHECKSUM=$(cat Dockerfile | sed -n "s/^ARG\s*${DOCKER_ARG_CHECKSUM}\s*=\s*\(\S*\).*/\1/p")

printinfo "Latest $NAME version: $LATEST_VERSION"
printinfo "Latest $NAME checksum (AMD64 sha256sum): $LATEST_CHECKSUM"
printinfo "Current $NAME version used: $CURRENT_VERSION"
printinfo "Current $NAME checksum used: $CURRENT_CHECKSUM"

update_message() {
    printwarn "$NAME is NOT up-to-date! Update to:\n"
    echo "ARG $DOCKER_ARG_VERSION=$LATEST_VERSION"
    echo "ARG $DOCKER_ARG_CHECKSUM=$LATEST_CHECKSUM"
    echo " "
}

echo " "

if [[ ! $CURRENT_VERSION || ! $LATEST_VERSION || $CURRENT_VERSION != $LATEST_VERSION ]]; then
    update_message
    exit 1
fi

if [[ ! $CURRENT_CHECKSUM || ! $LATEST_CHECKSUM || $CURRENT_CHECKSUM != $LATEST_CHECKSUM ]]; then
    update_message
    exit 1
fi

printsuccess "$NAME is up-to-date!"
echo " "
exit 0
