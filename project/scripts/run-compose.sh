#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-studyslot-verify}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-$(openssl rand -hex 24)}
if [[ ${KEEP_RUNNING:-0} != 1 ]]; then
  trap 'docker compose down -v' EXIT
fi
set -x
docker compose up --build -d --wait --wait-timeout 240
docker compose ps -a
docker compose exec -T backend id
docker compose exec -T frontend id
python3 scripts/check-api.py
docker compose exec -T postgres psql -U studyslot -d studyslot -c '\d bookings'
docker compose exec -T postgres psql -U studyslot -d studyslot -c 'SELECT * FROM alembic_version;'
docker image ls studyslot-backend
docker image ls studyslot-frontend
