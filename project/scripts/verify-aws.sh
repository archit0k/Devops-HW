#!/usr/bin/env bash
set -euo pipefail
[[ $(kubectl config current-context) == arn:aws:eks:*:cluster/archit-studyslot ]]
kubectl -n studyslot get deployments,pods,svc,pvc,ingress,hpa,servicemonitors
helm list -A
kubectl -n studyslot exec deploy/backend -- id
kubectl -n studyslot exec deploy/frontend -- id
kubectl -n ingress-nginx port-forward --address 127.0.0.1 svc/ingress-nginx-controller 3000:80 & p1=$!
kubectl -n studyslot port-forward --address 127.0.0.1 svc/backend 8000:8000 & p2=$!
trap 'kill "$p1" "$p2" 2>/dev/null || true' EXIT
for attempt in $(seq 1 60); do
  if curl -fsS http://localhost:8000/ready && curl -fsS http://localhost:3000/frontend-health; then break; fi
  sleep 2
done
python3 project/scripts/check-api.py
kubectl -n studyslot exec postgres-0 -- psql -U studyslot -d studyslot -c 'SELECT * FROM alembic_version;'
kubectl top pods -n studyslot
