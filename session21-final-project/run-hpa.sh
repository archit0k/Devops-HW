#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/taskboard"
[[ $(kubectl config current-context) == taskboard-lab ]]
set -x
helm upgrade taskboard ./helm/taskboard -n taskboard --reuse-values \
  --set replicaCount=2 --set hpa.enabled=true --wait --timeout 180s
# A short downscale window keeps this temporary demonstration bounded.
kubectl -n taskboard patch hpa taskboard-backend --type=merge \
  -p '{"spec":{"behavior":{"scaleDown":{"stabilizationWindowSeconds":60}}}}'
kubectl -n taskboard rollout status deploy/taskboard-taskboard-backend --timeout=180s
kubectl -n taskboard get hpa
kubectl top pods -n taskboard
mapfile -t pods < <(kubectl -n taskboard get pods -l app=taskboard-backend -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
load_pids=()
for pod in "${pods[@]}"; do
  kubectl -n taskboard exec "$pod" -- python -c \
    'import hashlib,time; end=time.monotonic()+180
while time.monotonic()<end: hashlib.pbkdf2_hmac("sha256", b"classroom", b"24BCS10194", 50000)' &
  load_pids+=("$!")
done
scaled=0
for attempt in $(seq 1 14); do
  kubectl -n taskboard get hpa
  kubectl -n taskboard get deploy taskboard-taskboard-backend
  count=$(kubectl -n taskboard get deploy taskboard-taskboard-backend -o jsonpath='{.spec.replicas}')
  if (( count >= 4 )); then scaled=1; fi
  sleep 15
done
for pid in "${load_pids[@]}"; do wait "$pid"; done
test "$scaled" = 1
kubectl -n taskboard describe hpa taskboard-backend
recovered=0
for attempt in $(seq 1 24); do
  kubectl -n taskboard get hpa
  count=$(kubectl -n taskboard get deploy taskboard-taskboard-backend -o jsonpath='{.spec.replicas}')
  if (( count == 2 )); then recovered=1; break; fi
  sleep 15
done
test "$recovered" = 1
kubectl -n taskboard rollout status deploy/taskboard-taskboard-backend --timeout=180s
kubectl -n taskboard get pods,hpa
echo 'HPA scaled above two replicas under bounded CPU load and recovered to two.'
