#!/usr/bin/env bash
set -euo pipefail
export PATH="/root/.minikube/cache/linux/amd64/v1.37.0:$PATH"
[[ $(kubectl config current-context) == minikube ]]
kubectl -n studyslot get deployments,pods,svc,pvc,ingress,hpa,servicemonitors
helm list -A
python3 project/scripts/check-api.py
python3 - <<'PY'
import json, urllib.parse, urllib.request
base = 'http://localhost:9090/api/v1/'
def fetch(path):
    with urllib.request.urlopen(base + path, timeout=30) as response:
        return json.load(response)
targets = fetch('targets')['data']['activeTargets']
app = [t for t in targets if t['labels'].get('namespace') == 'studyslot']
assert len(app) >= 2, app
for t in app:
    print('Prometheus target:', t['scrapeUrl'], t['health'], 'error:', t['lastError'])
    assert t['health'] == 'up' and not t['lastError']
for query in ['sum(up{namespace="studyslot"})',
              'sum(studyslot_http_requests_total{namespace="studyslot"})',
              'sum(rate(studyslot_http_requests_total{namespace="studyslot"}[5m]))',
              'histogram_quantile(0.95, sum by (le) (rate(studyslot_http_request_duration_seconds_bucket{namespace="studyslot"}[5m])))']:
    result = fetch('query?' + urllib.parse.urlencode({'query': query}))
    print(query, json.dumps(result['data']['result']))
    assert result['status'] == 'success' and result['data']['result']
print('Ingress, CRUD, real PostgreSQL conflict protection and Prometheus checks passed.')
PY
kubectl -n argocd get application studyslot
kubectl -n studyslot top pods
