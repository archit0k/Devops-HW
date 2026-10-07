#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/taskboard/backend"
password=$(openssl rand -hex 16)
export DATABASE_URL="postgresql+psycopg://taskboard:${password}@127.0.0.1:15433/taskboard"
docker run -d --name taskboard-direct-postgres -p 127.0.0.1:15433:5432 \
  -e POSTGRES_USER=taskboard -e POSTGRES_DB=taskboard -e POSTGRES_PASSWORD="$password" postgres:16-alpine
cleanup() {
  if [[ -n "${server:-}" ]]; then kill "$server" 2>/dev/null || true; wait "$server" 2>/dev/null || true; fi
  docker rm -f taskboard-direct-postgres
}
trap cleanup EXIT
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
set -x
for attempt in $(seq 1 60); do
  if docker exec taskboard-direct-postgres pg_isready -U taskboard; then break; fi
  [[ "$attempt" -lt 60 ]] || exit 1
  sleep 2
done
alembic upgrade head
alembic current
uvicorn app.main:app --host 127.0.0.1 --port 8000 > /tmp/taskboard-direct.log 2>&1 &
server=$!
for attempt in $(seq 1 30); do
  if curl -fsS http://localhost:8000/health; then break; fi
  [[ "$attempt" -lt 30 ]] || exit 1
  sleep 2
done
curl -fsS http://localhost:8000/api/tasks
curl -fsS http://localhost:8000/docs | grep -m 1 swagger-ui
curl -fsS -H 'Content-Type: application/json' \
  -d '{"title":"Session 21 direct backend","assignee":"Archit Kulkarni","priority":"MEDIUM"}' \
  http://localhost:8000/api/tasks
docker exec taskboard-direct-postgres psql -U taskboard -d taskboard -c 'SELECT id,title,status,assignee FROM tasks;'
cat /tmp/taskboard-direct.log
