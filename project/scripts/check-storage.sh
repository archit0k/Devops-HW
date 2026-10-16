#!/usr/bin/env bash
set -euo pipefail
export PATH="/root/.minikube/cache/linux/amd64/v1.37.0:$PATH"
[[ $(kubectl config current-context) == minikube ]]
query='SELECT id, student_name, room, booking_date, start_hour FROM bookings ORDER BY id;'
before=$(kubectl -n studyslot exec postgres-0 -- psql -U studyslot -d studyslot -At -c "$query")
pvc=$(kubectl -n studyslot get pvc data-postgres-0 -o jsonpath='{.metadata.uid}')
echo "PVC before: $pvc"
printf 'Rows before restart:\n%s\n' "$before"
kubectl -n studyslot delete pod postgres-0 --wait=true
kubectl -n studyslot wait --for=condition=Ready pod/postgres-0 --timeout=240s
after=$(kubectl -n studyslot exec postgres-0 -- psql -U studyslot -d studyslot -At -c "$query")
echo "PVC after: $(kubectl -n studyslot get pvc data-postgres-0 -o jsonpath='{.metadata.uid}')"
printf 'Rows after restart:\n%s\n' "$after"
[[ "$before" == "$after" ]]
[[ "$pvc" == "$(kubectl -n studyslot get pvc data-postgres-0 -o jsonpath='{.metadata.uid}')" ]]
echo 'PostgreSQL Pod recreated; the same PVC and all demo rows were preserved.'
