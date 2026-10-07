#!/usr/bin/env bash
set -euo pipefail
kubectl create secret generic yatri-db-secret \
  --from-literal=POSTGRES_USER=classroom \
  --from-literal=POSTGRES_DB=demo \
  --from-literal="POSTGRES_PASSWORD=$(openssl rand -hex 16)" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl get secret yatri-db-secret
