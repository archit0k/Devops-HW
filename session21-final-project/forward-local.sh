#!/usr/bin/env bash
# Loopback-only access for the temporary classroom demo. Ctrl-C closes all four.
set -euo pipefail
source "$(dirname "$0")/kube-lib.sh"
[[ "$lab_context" == minikube ]]
forward_pids=()
cleanup() {
  for pid in "${forward_pids[@]}"; do kill "$pid" 2>/dev/null || true; done
  wait || true
}
trap cleanup EXIT
trap 'exit 0' INT TERM
kubectl -n ingress-nginx port-forward --address=127.0.0.1 svc/ingress-nginx-controller 3000:80 &
forward_pids+=("$!")
kubectl -n taskboard port-forward --address=127.0.0.1 svc/taskboard-taskboard-backend 8000:8000 &
forward_pids+=("$!")
kubectl -n monitoring port-forward --address=127.0.0.1 svc/kube-prometheus-stack-prometheus 9090:9090 &
forward_pids+=("$!")
kubectl -n monitoring port-forward --address=127.0.0.1 svc/kube-prometheus-stack-grafana 3001:80 &
forward_pids+=("$!")
wait -n "${forward_pids[@]}"
