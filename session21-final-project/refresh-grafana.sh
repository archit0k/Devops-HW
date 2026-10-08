#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/kube-lib.sh"
[[ "$lab_context" == minikube ]]
set -x
# Same classroom Grafana version verified in Session 20, with its bundled plugins.
docker save grafana/grafana:12.1.1 | docker exec -i minikube ctr -n k8s.io images import -
kubectl -n monitoring set image deployment/kube-prometheus-stack-grafana grafana=grafana/grafana:12.1.1
kubectl -n monitoring rollout status deployment/kube-prometheus-stack-grafana --timeout=180s
kubectl -n monitoring get pods
