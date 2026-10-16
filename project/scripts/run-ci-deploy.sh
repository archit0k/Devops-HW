#!/usr/bin/env bash
set -euo pipefail
tag=${1:?Pass the scanned Git SHA}
[[ "$tag" =~ ^[0-9a-f]{40}$ ]]
[[ $(kubectl config current-context) == kind-studyslot-ci ]]
python3 project/scripts/bootstrap-secret.py
set -x
kubectl get nodes -o wide
helm lint project/helm/studyslot --set "imageTag=$tag"
helm upgrade --install studyslot project/helm/studyslot -n studyslot \
  --set "imageTag=$tag" --set ingress.enabled=false --set hpa.enabled=false --wait --timeout 300s
kubectl -n studyslot get pods,deploy,svc,pvc
helm list -n studyslot
kubectl -n studyslot exec deploy/backend -- id
kubectl -n studyslot exec deploy/frontend -- id
kubectl -n studyslot port-forward --address 127.0.0.1 svc/frontend 3000:8080 &
frontend_pid=$!
kubectl -n studyslot port-forward --address 127.0.0.1 svc/backend 8000:8000 &
backend_pid=$!
trap 'kill "$frontend_pid" "$backend_pid" 2>/dev/null || true' EXIT
for attempt in $(seq 1 60); do
  if curl -fsS http://localhost:8000/ready && curl -fsS http://localhost:3000/frontend-health; then break; fi
  sleep 2
done
python3 project/scripts/check-api.py
kubectl -n studyslot exec postgres-0 -- psql -U studyslot -d studyslot -c 'SELECT * FROM alembic_version;'
helm uninstall studyslot -n studyslot --wait
kubectl delete namespace studyslot --wait=true
