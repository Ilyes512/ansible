FROM alpine:3.9

WORKDIR /ansible

RUN apk add --no-cache --upgrade \
        curl \
        ansible \ 
    # Update pip and install openshift
    && python3 -m ensurepip \
    && pip3 install --upgrade --no-cache-dir --progress-bar off \
        pip \
        openshift \
    # Add symlinks for pip3 and pyton3 to pip and python
    && if [ ! -e /usr/bin/pip ]; then ln -s /usr/bin/pip3 /usr/bin/pip; fi \
    && if [ ! -e /usr/bin/python ]; then ln -s /usr/bin/python3 /usr/bin/python; fi \
    # Get kubectl
    && curl -fSLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

CMD ["ansible", "--version"]
