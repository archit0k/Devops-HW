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
forward() {
  local child=0
  trap 'if (( child > 0 )); then kill "$child" 2>/dev/null || true; fi; exit 0' INT TERM
  while true; do
    kubectl -n "$1" port-forward --address=127.0.0.1 "svc/$2" "$3" &
    child=$!
    wait "$child" || true
    # A rollout replaces the selected Pod. Reconnect only this lab forward.
    sleep 2
  done
}
forward ingress-nginx ingress-nginx-controller 3000:80 &
forward_pids+=("$!")
forward taskboard taskboard-taskboard-backend 8000:8000 &
forward_pids+=("$!")
forward monitoring kube-prometheus-stack-prometheus 9090:9090 &
forward_pids+=("$!")
forward monitoring kube-prometheus-stack-grafana 3001:80 &
forward_pids+=("$!")
wait -n "${forward_pids[@]}"
