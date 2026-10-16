#!/usr/bin/env bash
# Resume the preserved recording lab without reinstalling charts or deleting data.
set -euo pipefail
cd "$(dirname "$0")/../.."
export PATH="/root/.minikube/cache/linux/amd64/v1.37.0:$PATH"
systemctl start docker.service
if ! docker inspect minikube >/dev/null 2>&1; then
  echo 'The preserved Minikube container is missing. Stop and use the full setup instructions.' >&2
  exit 1
fi
docker update --memory 5g --memory-swap 7g --cpus 6 minikube
minikube start --driver=docker --force
kubectl config use-context minikube
kubectl -n studyslot rollout status statefulset/postgres --timeout=300s
kubectl -n studyslot rollout status deployment/backend --timeout=300s
kubectl -n studyslot rollout status deployment/frontend --timeout=300s
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=300s
kubectl -n monitoring rollout status deployment/monitoring-grafana --timeout=300s
kubectl -n argocd rollout status deployment/argocd-server --timeout=300s
kubectl -n kube-system rollout status deployment/metrics-server --timeout=180s
kubectl -n monitoring rollout status statefulset/prometheus-monitoring-kube-prometheus-prometheus --timeout=180s
kubectl -n argocd wait application/studyslot --for=jsonpath='{.status.health.status}'=Healthy --timeout=180s
kubectl -n studyslot get pods,svc,ingress,pvc,hpa
kubectl -n argocd get application studyslot
echo 'The preserved local lab is healthy. Keep forward-local.sh running in a separate shell.'
