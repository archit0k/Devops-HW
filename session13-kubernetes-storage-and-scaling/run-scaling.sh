#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
k() { minikube kubectl -- "$@"; }
set -x
k get nodes
k -n kube-system get deployment metrics-server
k top nodes
k apply -f mini-project/namespace.yaml
k apply -f mini-project/pvc.yaml -f mini-project/deployment.yaml -f mini-project/service.yaml -f mini-project/hpa.yaml
k -n production-webapp rollout status deployment/web-app --timeout=180s
k -n production-webapp get pods,pvc,hpa
k -n production-webapp exec deployment/web-app -- sh -c 'echo "Student: Archit Kulkarni - 24BCS10194" > /data/student.txt'
old=$(k -n production-webapp get pod -l app=web-app -o jsonpath='{.items[0].metadata.name}')
k -n production-webapp delete pod "$old"
k -n production-webapp rollout status deployment/web-app --timeout=120s
k -n production-webapp exec deployment/web-app -- cat /data/student.txt
loadpids=()
for pod in $(k -n production-webapp get pods -l app=web-app -o jsonpath='{.items[*].metadata.name}'); do
  k -n production-webapp exec "$pod" -- sh -c 'timeout 180s sh -c "yes >/dev/null"' &
  loadpids+=("$!")
done
scaled=0
for attempt in {1..35}; do
  k -n production-webapp get hpa
  k -n production-webapp top pods || true
  replicas=$(k -n production-webapp get deployment web-app -o jsonpath='{.spec.replicas}')
  if (( replicas > 2 )); then scaled=1; break; fi
  sleep 5
done
test "$scaled" = 1
k -n production-webapp rollout status deployment/web-app --timeout=120s
k -n production-webapp describe hpa web-app-hpa
k -n production-webapp get pods,pvc,hpa
for pid in "${loadpids[@]}"; do wait "$pid" || true; done
for attempt in {1..40}; do
  k -n production-webapp get hpa
  replicas=$(k -n production-webapp get deployment web-app -o jsonpath='{.spec.replicas}')
  [[ "$replicas" == 2 ]] && break
  sleep 5
done
test "$replicas" = 2
k -n production-webapp rollout status deployment/web-app --timeout=120s
k -n production-webapp get pods,pvc,hpa
k delete namespace production-webapp --wait=true
