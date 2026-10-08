#!/usr/bin/env bash
# Build the same frontend Dockerfile locally and refresh only the classroom app.
set -euo pipefail
source "$(dirname "$0")/kube-lib.sh"
[[ "$lab_context" == minikube ]]
tag=${1:?Pass the Git commit SHA being tested}
[[ "$tag" =~ ^[0-9a-f]{40}$ ]]
cd "$(dirname "$0")/taskboard"
set -x
image="ghcr.io/archit0k/taskboard-frontend:$tag"
docker build -t "$image" ./frontend
# Stream directly into the existing node; no second archive/cache copy.
docker save "$image" | docker exec -i minikube ctr -n k8s.io images import -
helm upgrade taskboard ./helm/taskboard -n taskboard --reuse-values \
  --set "frontend.tag=$tag" --wait --timeout 180s
kubectl -n taskboard get pods,hpa
