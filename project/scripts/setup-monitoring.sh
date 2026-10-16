#!/usr/bin/env bash
set -euo pipefail
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
python3 - <<'PY'
import base64,json,secrets,subprocess
check = subprocess.run(['kubectl','get','secret','studyslot-grafana','-n','monitoring'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
if check.returncode:
    fields={'admin-user':'archit','admin-password':secrets.token_hex(24)}
    document={'apiVersion':'v1','kind':'Secret','metadata':{'name':'studyslot-grafana','namespace':'monitoring'},
              'data':{k:base64.b64encode(v.encode()).decode() for k,v in fields.items()}}
    subprocess.run(['kubectl','apply','-f','-'],input=json.dumps(document),text=True,check=True)
PY
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
chart="$(helm env HELM_REPOSITORY_CACHE)/kube-prometheus-stack-89.2.0.tgz"
if [[ ! -f "$chart" ]]; then
  helm pull prometheus-community/kube-prometheus-stack --version 89.2.0 --destination "$(helm env HELM_REPOSITORY_CACHE)"
fi
helm upgrade --install monitoring "$chart" -n monitoring -f project/monitoring/values.yaml --wait --timeout 600s
kubectl apply -f project/monitoring/dashboard.yaml
kubectl -n monitoring get pods,svc
