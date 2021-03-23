FROM alpine:3.13.2

WORKDIR /ansible

# Latest version of Kubectl at the moment: https://storage.googleapis.com/kubernetes-release/release/stable.txt
ARG KUBECTL_VERSION=v1.20.5
# Latest version of Kubectx at the moment: https://api.github.com/repos/ahmetb/kubectx/releases/latest
ARG KUBECTX_VERSION=v0.9.3

RUN apk add --no-cache --upgrade --no-progress \
        curl \
        openssl \
        ca-certificates \
        python3 \
        git \
        docker-cli \
        openssh-client \
        sudo \
    && apk add --no-cache --upgrade --no-progress --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        openssl-dev \
        build-base \
        rust \
        cargo \
    && python3 -m ensurepip \
    && python3 -m pip install --upgrade --no-cache-dir --progress-bar off \
        pip \
    && python3 -m pip install --upgrade --no-cache-dir --progress-bar off \
        cffi \
        cryptography \
        # for more Ansible password_hash() support (ie bcrypt)
        passlib \
        bcrypt \
        ansible \
        # openshift is a requirement of the k8s Ansible module
        openshift \
        # needed for Ansible k8s module's validate support
        kubernetes-validate \
        # needed for Ansible dns lookup support
        dnspython \
        # needed for Ansible ipaddr functions
        netaddr \
    && apk del build-dependencies \
    # add symlinks for pip3 and pyton3 to pip and python
    && if [ ! -e /usr/bin/pip ]; then ln -s /usr/bin/pip3 /usr/bin/pip; fi \
    && if [ ! -e /usr/bin/python ]; then ln -s /usr/bin/python3 /usr/bin/python; fi \
    # get kubectl
    && curl -fsSLo /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl" \
    && chmod +x /usr/local/bin/kubectl \
    # get kubectx
    && curl -fsSLo /usr/local/bin/kubectx "https://raw.githubusercontent.com/ahmetb/kubectx/$KUBECTX_VERSION/kubectx" \
    && chmod +x /usr/local/bin/kubectx \
    # get kubens
    && curl -fsSLo /usr/local/bin/kubens "https://raw.githubusercontent.com/ahmetb/kubectx/$KUBECTX_VERSION/kubens" \
    && chmod +x /usr/local/bin/kubens \
    && rm -rf /tmp/*

ARG USERNAME=ansible
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN addgroup -g $USER_GID $USERNAME \
    && adduser -s /bin/sh -G $USERNAME -D -g '' -u $USER_UID $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && chown $USERNAME: /ansible

COPY files /

USER $USERNAME

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["ansible", "--version"]
