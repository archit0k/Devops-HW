#!/usr/bin/env bash
set -euo pipefail
version=v1.35.9
curl -fsSL --retry 3 -o /tmp/taskboard-kubectl "https://dl.k8s.io/release/$version/bin/linux/amd64/kubectl"
curl -fsSL --retry 3 -o /tmp/taskboard-kubectl.sha256 "https://dl.k8s.io/release/$version/bin/linux/amd64/kubectl.sha256"
cd /tmp
printf '%s  taskboard-kubectl\n' "$(cat taskboard-kubectl.sha256)" | sha256sum -c -
install -m755 taskboard-kubectl /usr/local/bin/kubectl
kubectl version --client
helm version --short
docker load -i '/mnt/c/Users/archi/Github Projects/Devops-HW/private-evidence/taskboard-images.tar.gz'
