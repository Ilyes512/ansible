ARG DOCKER_REGISTRY_HOST=docker.io
ARG DOCKER_POSTGRES_IMAGE_NAME=library/debian
ARG DOCKER_DEBIAN_IMAGE_TAG=11.3
FROM $DOCKER_REGISTRY_HOST/$DOCKER_POSTGRES_IMAGE_NAME:$DOCKER_DEBIAN_IMAGE_TAG

RUN apt-get update \
    && apt-get install --assume-yes --no-install-recommends \
        python3 \
        python3-pip \
    && python3 -m pip install --upgrade --no-cache-dir --progress-bar off \
        pip \
        wheel \
        setuptools \
    && python3 -m pip install --no-cache-dir --progress-bar off \
        # for better Ansible password_hash() support
        passlib \
        bcrypt \
        # openshift is a requirement of the k8s Ansible module
        openshift \
        # needed for Ansible k8s module's validate support
        kubernetes-validate \
        # needed for Ansible dns lookup support
        dnspython \
        # needed for Ansible ipaddr functions
        netaddr \
        # needed for Ansible hashi_vault plugin support
        hvac \
        # needed for Ansible docker \
        docker \
        # misc
        ansible-lint \
        yamllint \
        molecule[docker] \
        # ...
        ansible

CMD ["python3", "-m", "pip", "freeze", "--all"]
