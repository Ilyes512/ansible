ARG DOCKER_REGISTRY_HOST=docker.io
ARG DOCKER_POSTGRES_IMAGE_NAME=library/debian
ARG DOCKER_DEBIAN_IMAGE_TAG=11.3
FROM $DOCKER_REGISTRY_HOST/$DOCKER_POSTGRES_IMAGE_NAME:$DOCKER_DEBIAN_IMAGE_TAG AS builder

ARG UNIQUE_ID_FOR_CACHEFROM=builder

WORKDIR /ansible

RUN apt-get update \
    && apt-get install --assume-yes --no-install-recommends \
        build-essential \
        gcc \
        python3 \
        python3-pip \
        python3-venv \
    && python3 -m pip install --upgrade --no-cache-dir --progress-bar off \
        pip \
        wheel \
        setuptools \
    && python3 -m venv /opt/venv \
    && apt-get autoremove --assume-yes \
    && apt-get clean --assume-yes \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt /ansible/requirements.txt

RUN python3 -m pip install --no-cache-dir --progress-bar off wheel \
    && python3 -m pip install --no-cache-dir --progress-bar off --requirement /ansible/requirements.txt

FROM $DOCKER_REGISTRY_HOST/$DOCKER_POSTGRES_IMAGE_NAME:$DOCKER_DEBIAN_IMAGE_TAG AS ansible

ARG UNIQUE_ID_FOR_CACHEFROM=ansible

ENV HOME /home

WORKDIR /ansible

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN chmod 777 -R "$HOME" \
    && apt-get update \
    && apt-get install --assume-yes --no-install-recommends \
        ca-certificates \
        curl \
        openssl \
        git \
        openssh-client \
        python3 \
        python3-distutils \
        jq \
        # deps for docker-ce-cli
        gnupg \
        lsb-release \
        software-properties-common \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor - > /usr/share/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker-ce.list \
    && apt-get update \
    && apt-get install --assume-yes --no-install-recommends docker-ce-cli \
    # Ansible requires the running user to have a passwd entry
    && for i in $(seq 500 1999); do echo "user:x:$i:$i::/home:/sbin/nologin"; done >> /etc/passwd \
    && apt-get purge --assume-yes \
        gnupg \
        lsb-release \
        software-properties-common \
    && apt-get autoremove --assume-yes \
    && apt-get clean --assume-yes \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

COPY files/ansible /
COPY --from=builder /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

FROM ansible AS k8s

ARG UNIQUE_ID_FOR_CACHEFROM=ansiblek8s

# Latest version of Kubectl at the moment: https://storage.googleapis.com/kubernetes-release/release/stable.txt
ARG KUBECTL_VERSION=v1.24.0
ARG KUBECTL_SHA256=94d686bb6772f6fb59e3a32beff908ab406b79acdfb2427abdc4ac3ce1bb98d7
# Latest version of kubectx/kubens at the moment: https://api.github.com/repos/ahmetb/kubectx/releases/latest
ARG KUBECTX_VERSION=v0.9.4
ARG KUBECTX_SHA256=db5a48e85ff4d8c6fa947e3021e11ba4376f9588dd5fa779a80ed5c18287db22
ARG KUBENS_SHA256=8b3672961fb15f8b87d5793af8bd3c1cca52c016596fbf57c46ab4ef39265fcd
# Latest version of Helm at the moment: https://api.github.com/repos/helm/helm/releases/latest
ARG HELM_VERSION=v3.8.2
ARG HELM_SHA256=6cb9a48f72ab9ddfecab88d264c2f6508ab3cd42d9c09666be16a7bf006bed7b

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

    # get kubectl
RUN curl -fsSLo /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl" \
    && echo "$KUBECTL_SHA256 */usr/local/bin/kubectl" | sha256sum -c - \
    && chmod +x /usr/local/bin/kubectl \
    # get kubectx
    && curl -fsSLo /tmp/kubectx.tar.gz "https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_VERSION/kubectx_${KUBECTX_VERSION}_linux_x86_64.tar.gz" \
    && echo "$KUBECTX_SHA256 */tmp/kubectx.tar.gz" | sha256sum -c - \
    && tar -xf /tmp/kubectx.tar.gz -C /usr/local/bin kubectx \
    && chmod +x /usr/local/bin/kubectx \
    # get kubens
    && curl -fsSLo /tmp/kubens.tar.gz "https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_VERSION/kubens_${KUBECTX_VERSION}_linux_x86_64.tar.gz" \
    && echo "$KUBENS_SHA256 */tmp/kubens.tar.gz" | sha256sum -c - \
    && tar -xf /tmp/kubens.tar.gz -C /usr/local/bin kubens \
    && chmod +x /usr/local/bin/kubens \
    # get helm
    && curl -fsSLo /tmp/helm.tar.gz "https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz" \
    && echo "$HELM_SHA256 */tmp/helm.tar.gz" | sha256sum -c - \
    && tar -xf /tmp/helm.tar.gz -C /usr/local/bin --strip-components=1 linux-amd64/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf /tmp/*

COPY files/ansiblek8s /

ENTRYPOINT ["docker-entrypoint.sh"]
