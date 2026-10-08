#!/usr/bin/env bash
set -euo pipefail
[[ $(kubectl config current-context) == taskboard-lab ]]
set -x
kubectl -n taskboard get pvc taskboard-postgres-data
kubectl -n taskboard exec deploy/taskboard-postgres -- psql -U taskboard -d taskboard \
  -c 'SELECT id,title,status,assignee FROM tasks ORDER BY id;'
old_pod=$(kubectl -n taskboard get pod -l app=taskboard-postgres -o jsonpath='{.items[0].metadata.name}')
old_uid=$(kubectl -n taskboard get pod "$old_pod" -o jsonpath='{.metadata.uid}')
kubectl -n taskboard delete pod "$old_pod" --wait=true
kubectl -n taskboard rollout status deploy/taskboard-postgres --timeout=300s
new_uid=$(kubectl -n taskboard get pod -l app=taskboard-postgres -o jsonpath='{.items[0].metadata.uid}')
test "$old_uid" != "$new_uid"
kubectl -n taskboard exec deploy/taskboard-postgres -- psql -U taskboard -d taskboard \
  -c 'SELECT id,title,status,assignee FROM tasks ORDER BY id;'
count=$(kubectl -n taskboard exec deploy/taskboard-postgres -- psql -U taskboard -d taskboard -At \
  -c "SELECT count(*) FROM tasks WHERE title='Verify TaskBoard PVC - 24BCS10194';")
test "$count" = 1
curl --fail --max-time 20 http://localhost:8000/ready
echo 'The row survived a different PostgreSQL Pod UID using the same Bound PVC.'
