#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/monitoring"
compose() { docker compose -f compose.yaml "$@"; }
trap 'compose start grafana' EXIT
set -x
compose restart prometheus
sleep 15
curl -fsS 'http://localhost:9090/api/v1/query?query=up'
compose stop grafana
for attempt in $(seq 1 30); do
  alerts=$(curl -fsS http://localhost:9090/api/v1/alerts)
  echo "$alerts"
  if grep -q '"state":"firing"' <<< "$alerts"; then break; fi
  [[ "$attempt" -lt 30 ]] || exit 1
  sleep 2
done
compose start grafana
sleep 15
curl -fsS 'http://localhost:9090/api/v1/query?query=up'
curl -fsS http://localhost:9090/api/v1/alerts
