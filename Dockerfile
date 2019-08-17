FROM alpine:3.10.1

WORKDIR /ansible

ENV KUBECTL_VERSION v1.15.2

RUN apk add --no-cache --upgrade \
        curl \
        openssl \
        ca-certificates \
        python3 \
        git \
    && apk add --no-cache --upgrade --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        openssl-dev \
        build-base \
    && python3 -m ensurepip \
    && pip3 install --upgrade --no-cache-dir --progress-bar off \
        pip \
        cffi \
    && pip3 install --upgrade --no-cache-dir --progress-bar off \
        cryptography \
        # For more Ansible password_hash() support (ie bcrypt)
        passlib \
        bcrypt \
        ansible \
        mazer \
        # Openshift is a requirement of the k8s Ansible module
        openshift \
    && apk del build-dependencies \
    # Add symlinks for pip3 and pyton3 to pip and python
    && if [ ! -e /usr/bin/pip ]; then ln -s /usr/bin/pip3 /usr/bin/pip; fi \
    && if [ ! -e /usr/bin/python ]; then ln -s /usr/bin/python3 /usr/bin/python; fi \
    # Get kubectl
    && curl -fsSLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

COPY files /

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["ansible", "--version"]
