#!/usr/bin/env bash
set -euo pipefail
tag=${1:?Pass a tested SHA}
[[ "$tag" =~ ^[0-9a-f]{40}$ ]]
if ! minikube status >/dev/null 2>&1; then
  minikube start --driver=docker --memory=4096 --cpus=4 --force
fi
docker update --memory 4g --memory-swap 6g --cpus 4 minikube
export PATH="/root/.minikube/cache/linux/amd64/v1.37.0:$PATH"
kubectl config use-context minikube
minikube addons enable ingress
minikube addons enable metrics-server
for app in backend frontend; do
  image="ghcr.io/archit0k/studyslot-$app:$tag"
  if minikube image ls | grep -Fxq "$image"; then continue; fi
  # Stream the scanned image to containerd instead of keeping a second archive.
  docker save "$image" | docker exec -i minikube ctr -n k8s.io images import --platform linux/amd64 -
done
minikube image load postgres:17-alpine
kubectl -n ingress-nginx rollout status deploy/ingress-nginx-controller --timeout=240s
kubectl -n kube-system rollout status deploy/metrics-server --timeout=240s
bash project/scripts/setup-monitoring.sh
python3 project/scripts/bootstrap-secret.py
helm upgrade --install studyslot project/helm/studyslot -n studyslot --set "imageTag=$tag" \
  --set ingress.host=localhost --set monitoring.serviceMonitor=true --wait --timeout 300s
kubectl -n studyslot get deployments,pods,svc,pvc,ingress,hpa,servicemonitors
helm list -A
