FROM alpine:3.11.3

WORKDIR /ansible

ENV HOME /home
ENV KUBECTL_VERSION v1.17.2
ENV KUBECTX_VERSION v0.7.1

RUN apk add --no-cache --upgrade --no-progress \
        curl \
        openssl \
        ca-certificates \
        python3 \
        git \
        docker-cli \
        openssh-client \
    && apk add --no-cache --upgrade --no-progress --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        openssl-dev \
        build-base \
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


COPY files /

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["ansible", "--version"]
