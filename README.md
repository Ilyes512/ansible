# AnsibleK8s

[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/ilyes512/ansiblek8s.svg)](https://hub.docker.com/r/ilyes512/ansiblek8s)
[![Docker Pulls](https://img.shields.io/docker/pulls/ilyes512/ansiblek8s.svg)](https://hub.docker.com/r/ilyes512/ansiblek8s)
[![MicroBadger Size](https://img.shields.io/microbadger/image-size/ilyes512/ansiblek8s.svg)](https://microbadger.com/images/ilyes512/ansiblek8s)
[![MicroBadger Layers](https://img.shields.io/microbadger/layers/ilyes512/ansiblek8s.svg)](https://microbadger.com/images/ilyes512/ansiblek8s)

A image based on Alpine with Ansible and Kubectl.

## Pulling the image

```
docker pull ilyes512/ansiblek8s:latest
```

## Building the docker image(s)

```
docker build --tag ilyes512/ansiblek8s:fromsource .
```

## Misc

**Workdir**: `/ansible`

**Environment variables**:

`KUBECONFIG_OVERRIDE`: If this env variable is set, it will put the variable contents a (new) file at `/root/.kube/context-override`. It then set's the `KUBECONFIG` env variable to `/root/.kube/context-override`.

<details><summary>Example:</summary>

```bash
docker run --rm --tty --env KUBECONFIG_OVERRIDE="`kind get kubeconfig --internal`" ilyes512/ansiblek8s kubectl get nodes
```

Quote:
> kind is a tool for running local Kubernetes clusters using Docker container "nodes".

For more info see: https://github.com/kubernetes-sigs/kind
</details>