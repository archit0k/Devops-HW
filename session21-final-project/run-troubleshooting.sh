#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/kube-lib.sh"
cd "$(dirname "$0")/taskboard"
set -x
kubectl apply -f troubleshooting/broken-image.yaml
for attempt in $(seq 1 24); do
  reason=$(kubectl -n taskboard get pods -l app=broken-image -o jsonpath='{.items[0].status.containerStatuses[0].state.waiting.reason}')
  if [[ "$reason" == ImagePullBackOff || "$reason" == ErrImagePull ]]; then break; fi
  sleep 5
done
[[ "$reason" == ImagePullBackOff || "$reason" == ErrImagePull ]]
kubectl -n taskboard get pods -l app=broken-image
pod=$(kubectl -n taskboard get pods -l app=broken-image -o jsonpath='{.items[0].metadata.name}')
kubectl -n taskboard describe pod "$pod"
kubectl -n taskboard get events --sort-by=.lastTimestamp
# Reuse the working backend's image, Secret reference and readiness checks.
kubectl -n taskboard get deploy taskboard-taskboard-backend -o json | python3 -c \
  'import json,sys; d=json.load(sys.stdin); print(json.dumps({"spec":{"template":{"spec":{"containers":d["spec"]["template"]["spec"]["containers"]}}}}))' | \
  kubectl -n taskboard patch deploy taskboard-broken-image --type=strategic --patch-file=/dev/stdin
kubectl -n taskboard rollout status deploy/taskboard-broken-image --timeout=180s
kubectl -n taskboard get pods -l app=broken-image
kubectl -n taskboard exec deploy/taskboard-broken-image -- python -c \
  'import urllib.request; print(urllib.request.urlopen("http://127.0.0.1:8000/ready").read().decode())'
kubectl apply -f troubleshooting/broken-service.yaml
kubectl -n taskboard get svc broken-service
kubectl -n taskboard get endpoints broken-service
kubectl -n taskboard get pods --show-labels
test -z "$(kubectl -n taskboard get endpoints broken-service -o jsonpath='{.subsets[*].addresses[*].ip}')"
kubectl -n taskboard patch svc broken-service --type=merge \
  -p '{"spec":{"selector":{"app":"taskboard-backend"},"ports":[{"port":8080,"targetPort":8000}]}}'
for attempt in $(seq 1 12); do
  addresses=$(kubectl -n taskboard get endpoints broken-service -o jsonpath='{.subsets[*].addresses[*].ip}')
  if [[ -n "$addresses" ]]; then break; fi
  sleep 5
done
test -n "$addresses"
kubectl -n taskboard get endpoints broken-service
kubectl -n taskboard exec deploy/taskboard-taskboard-backend -- python -c \
  'import urllib.request; print(urllib.request.urlopen("http://broken-service:8080/health", timeout=10).read().decode())'
kubectl -n taskboard delete deploy taskboard-broken-image
kubectl -n taskboard delete svc broken-service
