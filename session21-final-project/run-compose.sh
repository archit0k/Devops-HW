#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/taskboard"
export POSTGRES_PASSWORD="$(openssl rand -hex 16)"
trap 'docker compose down' EXIT
set -x
docker compose up --build -d
docker compose ps -a
for attempt in $(seq 1 60); do
  if curl -fsS http://localhost:8000/ready; then break; fi
  [[ "$attempt" -lt 60 ]] || exit 1
  sleep 2
done
curl -fsS http://localhost:8000/health
curl -fsS http://localhost:8000/docs | grep -m 1 'swagger-ui'
curl -fsS http://localhost:8000/metrics
curl --retry 10 --retry-connrefused --retry-delay 2 -fsS http://localhost:3000/ | grep '<title>TaskBoard</title>'
created=$(curl -fsS -H 'Content-Type: application/json' -d '{"title":"Archit DevOps lab","assignee":"Archit Kulkarni","priority":"HIGH"}' http://localhost:3000/api/tasks)
echo "$created"
id=$(python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])' <<< "$created")
curl -fsS "http://localhost:8000/api/tasks/$id"
curl -fsS -X PUT -H 'Content-Type: application/json' -d '{"status":"DONE"}' "http://localhost:8000/api/tasks/$id"
docker compose exec -T postgres psql -U taskboard -d taskboard -c 'SELECT id,title,status,assignee FROM tasks;'
curl -fsS -X DELETE "http://localhost:8000/api/tasks/$id"
test "$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:8000/api/tasks/$id")" = 404
docker images --format '{{.Repository}}:{{.Tag}} {{.Size}}' | grep taskboard
docker compose exec -T backend id
docker compose logs --tail=20 backend
