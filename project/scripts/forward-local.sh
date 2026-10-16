#!/usr/bin/env bash
set -euo pipefail
export PATH="/root/.minikube/cache/linux/amd64/v1.37.0:$PATH"
[[ $(kubectl config current-context) == minikube ]]
pids=()
cleanup() { for pid in "${pids[@]}"; do kill "$pid" 2>/dev/null || true; done; wait || true; }
trap cleanup EXIT
trap 'exit 0' INT TERM
forward() {
  local child=0
  trap 'if (( child > 0 )); then kill "$child" 2>/dev/null || true; fi; exit 0' INT TERM
  while true; do
    kubectl -n "$1" port-forward --address=127.0.0.1 "svc/$2" "$3" &
    child=$!
    wait "$child" || true
    sleep 2
  done
}
forward ingress-nginx ingress-nginx-controller 3000:80 & pids+=("$!")
forward studyslot backend 8000:8000 & pids+=("$!")
forward monitoring monitoring-kube-prometheus-prometheus 9090:9090 & pids+=("$!")
forward monitoring monitoring-grafana 3001:80 & pids+=("$!")
forward argocd argocd-server 8081:80 & pids+=("$!")
wait -n "${pids[@]}"
