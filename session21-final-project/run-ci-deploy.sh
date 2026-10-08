#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/taskboard"
tag=${1:?pass the tested image SHA}
[[ $(kubectl config current-context) == kind-taskboard-ci ]]
kubectl apply -f k8s/namespace.yaml
python3 - <<'PY'
import base64,json,secrets,subprocess
password=secrets.token_hex(24)
fields={"username":"taskboard","password":password,
        "database-url":f"postgresql+psycopg://taskboard:{password}@taskboard-postgres:5432/taskboard"}
document={"apiVersion":"v1","kind":"Secret","metadata":{"name":"taskboard-postgres","namespace":"taskboard"},
          "data":{key:base64.b64encode(value.encode()).decode() for key,value in fields.items()}}
subprocess.run(["kubectl","apply","-f","-"],input=json.dumps(document),text=True,check=True)
PY
set -x
helm upgrade --install taskboard ./helm/taskboard -n taskboard --create-namespace \
  --set "backend.tag=$tag" --set "frontend.tag=$tag" --set replicaCount=1 \
  --set hpa.enabled=false --set monitoring.serviceMonitor.enabled=false --wait --timeout 240s
kubectl -n taskboard get deployments,pods,svc,pvc
kubectl -n taskboard port-forward svc/taskboard-taskboard-backend 8000:8000 > /tmp/taskboard-backend-forward.txt 2>&1 &
backend_pid=$!
kubectl -n taskboard port-forward svc/taskboard-frontend 8080:80 > /tmp/taskboard-frontend-forward.txt 2>&1 &
frontend_pid=$!
trap 'kill "$backend_pid" "$frontend_pid" 2>/dev/null || true' EXIT
for attempt in $(seq 1 30); do
  if curl -fsS http://localhost:8000/ready; then break; fi
  sleep 2
done
curl -fsS http://localhost:8080 | grep '<div id="root">'
python3 - <<'PY'
import json,urllib.request
base="http://localhost:8000"
payload=json.dumps({"title":"CI deployment check - 24BCS10194","assignee":"Archit Kulkarni"}).encode()
with urllib.request.urlopen(urllib.request.Request(base+"/api/tasks",data=payload,headers={"Content-Type":"application/json"}),timeout=10) as r:
    assert r.status==201
    task=json.load(r)
    print("Created on Kubernetes:",task)
with urllib.request.urlopen(base+"/api/tasks",timeout=10) as r:
    assert any(item["id"]==task["id"] for item in json.load(r))
with urllib.request.urlopen(urllib.request.Request(base+f'/api/tasks/{task["id"]}',method="DELETE"),timeout=10) as r:
    assert r.status==204
print("Kubernetes deployment and database-backed API checks passed.")
PY
helm status taskboard -n taskboard
helm uninstall taskboard -n taskboard
kubectl delete namespace taskboard --wait=true
