#!/usr/bin/env bash
# Remove only the temporary TaskBoard/monitoring releases; keep the existing cluster.
set -euo pipefail
source "$(dirname "$0")/kube-lib.sh"
[[ "$lab_context" == minikube ]]
set -x
kubectl -n taskboard exec deploy/taskboard-postgres -- pg_dump -U taskboard -d taskboard \
  --data-only --column-inserts --table=tasks
pkill -TERM -f '^bash session21-final-project/forward-local.sh$' || true
helm uninstall taskboard -n taskboard --wait --timeout 120s
helm uninstall kube-prometheus-stack -n monitoring --wait --timeout 180s
kubectl delete namespace taskboard monitoring --wait=true --timeout=180s
minikube stop
# Restore the reused Docker container's original resource limits while stopped.
docker update --memory 2g --memory-swap 3g --cpus 2 minikube
docker ps --format '{{.Names}} {{.Status}}'
minikube status || true
