#!/usr/bin/env bash
set -euo pipefail
export PATH="/root/.minikube/cache/linux/amd64/v1.37.0:$PATH"
[[ $(kubectl config current-context) == minikube ]]
kubectl -n studyslot get pods,svc,pvc,ingress,hpa
kubectl -n argocd get application studyslot
mkdir -p private-evidence
kubectl -n studyslot exec postgres-0 -- pg_dump -U studyslot -d studyslot --no-owner --no-acl > private-evidence/studyslot-backup.sql
test -s private-evidence/studyslot-backup.sql
echo 'Saved the local demo database in ignored private-evidence/studyslot-backup.sql.'
pids=$(pgrep -f '^bash project/scripts/forward-local.sh$' || true)
if [[ -n "$pids" ]]; then kill -TERM $pids 2>/dev/null || true; fi
minikube stop
docker update --memory 2g --memory-swap 3g --cpus 2 minikube
echo 'Restored the stopped Minikube container to its original 2 GiB / two CPU limits.'
docker ps --format '{{.Names}}'
if [[ -z $(docker ps -q) ]]; then
  systemctl stop docker.service docker.socket containerd.service
  echo 'Docker and containerd stopped. Demo PVCs and the SQL backup are preserved.'
else
  echo 'Other containers remain, so their Docker daemon was left running.'
fi
