#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/kube-lib.sh"
[[ "$lab_context" == minikube ]]
cd "$(dirname "$0")/taskboard"
tag=25ef8e537db59c165ce4e9fe8f6d4c2e1d4e787f
kubectl get nodes -o wide
kubectl apply -f k8s/namespace.yaml
minikube image load postgres:16-alpine
python3 - <<'PY'
import base64, json, secrets, subprocess
def secret(namespace, name, fields):
    existing=subprocess.run(["kubectl","get","secret",name,"-n",namespace],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    if existing.returncode == 0:
        print(f"Reusing existing {namespace}/{name} Secret (values not displayed).")
        return
    document={"apiVersion":"v1","kind":"Secret","metadata":{"namespace":namespace,"name":name},
              "data":{key:base64.b64encode(value.encode()).decode() for key,value in fields.items()}}
    subprocess.run(["kubectl","apply","-f","-"],input=json.dumps(document),text=True,check=True)
password=secrets.token_hex(24)
secret("taskboard","taskboard-postgres",{"username":"taskboard","password":password,
       "database-url":f"postgresql+psycopg://taskboard:{password}@taskboard-postgres:5432/taskboard"})
namespace={"apiVersion":"v1","kind":"Namespace","metadata":{"name":"monitoring"}}
subprocess.run(["kubectl","apply","-f","-"],input=json.dumps(namespace),text=True,check=True)
secret("monitoring","taskboard-grafana",{"admin-user":"archit","admin-password":secrets.token_hex(24)})
PY
set -x
monitoring_chart="$(helm env HELM_REPOSITORY_CACHE)/kube-prometheus-stack-89.2.0.tgz"
if [[ ! -f "$monitoring_chart" ]]; then
  helm pull prometheus-community/kube-prometheus-stack --version 89.2.0 --destination "$(helm env HELM_REPOSITORY_CACHE)"
fi
helm upgrade --install kube-prometheus-stack "$monitoring_chart" \
  --version 89.2.0 -n monitoring -f monitoring/prometheus-values.yaml -f monitoring/values-lab.yaml \
  --set grafana.admin.existingSecret=taskboard-grafana --wait --timeout 600s
kubectl apply -f ../grafana-dashboard.yaml
helm lint helm/taskboard
helm upgrade --install taskboard ./helm/taskboard -n taskboard --create-namespace \
  -f helm/taskboard/values-dev.yaml --set ingress.host=localhost \
  --set "backend.tag=$tag" --set "frontend.tag=$tag" --wait --timeout 300s
kubectl -n taskboard get deployments,pods,svc,pvc,ingress,servicemonitors
kubectl -n taskboard exec deploy/taskboard-taskboard-backend -- id
kubectl -n taskboard exec deploy/taskboard-postgres -- psql -U taskboard -d taskboard -c 'SELECT version();'
kubectl top nodes
helm list -A
