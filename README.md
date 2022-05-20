# ansible

[![Build Images](https://github.com/Ilyes512/ansible/workflows/Build%20Images/badge.svg)](https://github.com/Ilyes512/ansible/actions?query=workflow%3A%22Build+Images%22)

Multiple Ansible images with different kind of tools ready for K8s interactions.

## Pulling the images

```
docker pull ghcr.io/ilyes512/ansible:latest
docker pull ghcr.io/ilyes512/ansible:k8s-latest
```

## Task commands

Available [Task](https://taskfile.dev/#/) commands:

```
* a:shell:                      Interactive shell with Ansible
* act:master:                   Run Act with push event on master branch
* act:pr:                       Run Act with pull_request event
* act:tag:                      Run Act with tag (push) event
* build:                        Build and run new.Dockerfile
* lint:                         Apply a Dockerfile linter (https://github.com/hadolint/hadolint)
* requirements:                 Update requirements.txt file
* scripts:check-versions:       Check kubctl and kubectx versions
```

### Act tasks

[Act](https://github.com/nektos/act) is a tool to run Github Actions locally. Before you can run Act and the
`act:*`-tasks you need to add an `GITHUB_TOKEN`-secret. You can do this by adding the following
Act config file to you users `$HOME`-directory:

File path: `~/.actrc`
```
-s GITHUB_TOKEN=<your_github_token>
```

Replace `<your_github_token>` with a Github personal acces token. You can generate a new token
[here](https://github.com/settings/tokens/new?description=Act) (no scopes
are needed!).

## Misc

**Workdir**: `/ansible`

**Environment variables**:

`KUBECONFIG_OVERRIDE`: If this env variable is set, it will put the contents of the variable in a (new) file at `/root/.kube/context-override`. The path of the new file is then set as the value of `KUBECONFIG`-env.

<details><summary>Example:</summary>

```bash
docker run --rm --tty --env KUBECONFIG_OVERRIDE="`kind get kubeconfig --internal`" ghcr.io/ilyes512/ansible:k8s-latest kubectl get nodes
```

Quote:
> kind is a tool for running local Kubernetes clusters using Docker container "nodes".

For more info see: https://github.com/kubernetes-sigs/kind
</details>

**Build arguments**:

The following build arguments can be set (the values shown are the default values):

`DOCKER_REGISTRY_HOST`: `docker.io`
`DOCKER_POSTGRES_IMAGE_NAME`: `library/debian`
`DOCKER_DEBIAN_IMAGE_TAG`: `11.3`

<details><summary>Example:</summary>

```bash
docker build --build-arg DOCKER_DEBIAN_IMAGE_TAG=11.0 --tag ghcr.io/ilyes512/ansible:k8s-latest .  
```
</details>
