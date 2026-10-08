#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/taskboard"
export PATH="/root/.local/bin:$PATH"
tag=25ef8e537db59c165ce4e9fe8f6d4c2e1d4e787f
account=$(aws sts get-caller-identity --profile devops-homework --query Account --output text)
registry="$account.dkr.ecr.ap-south-1.amazonaws.com"
role="arn:aws:iam::$account:role/archit-taskboard-lab-access"
aws eks update-kubeconfig --profile devops-homework --region ap-south-1 \
  --name taskboard-eks --role-arn "$role" --alias taskboard-lab
kubectl config use-context taskboard-lab
kubectl wait --for=condition=Ready nodes --all --timeout=300s
kubectl get nodes -o wide
aws eks describe-addon --profile devops-homework --region ap-south-1 \
  --cluster-name taskboard-eks --addon-name aws-ebs-csi-driver --query addon.status --output text
aws eks describe-addon --profile devops-homework --region ap-south-1 \
  --cluster-name taskboard-eks --addon-name metrics-server --query addon.status --output text
aws ecr get-login-password --profile devops-homework --region ap-south-1 | \
  docker login --username AWS --password-stdin "$registry"
for component in backend frontend; do
  docker tag "ghcr.io/archit0k/taskboard-$component:$tag" "$registry/archit-taskboard-lab/$component:$tag"
  docker push "$registry/archit-taskboard-lab/$component:$tag"
done
kubectl apply -f k8s/namespace.yaml
kubectl apply -f ../gp3.yaml
# Generate classroom credentials without putting their values in logs or Git.
python3 - <<'PY'
import base64, json, secrets, subprocess
password = secrets.token_hex(24)
def secret(namespace, name, fields):
    document = {"apiVersion":"v1", "kind":"Secret", "metadata":{"namespace":namespace,"name":name},
                "type":"Opaque", "data":{key:base64.b64encode(value.encode()).decode() for key,value in fields.items()}}
    subprocess.run(["kubectl","apply","-f","-"], input=json.dumps(document), text=True, check=True)
secret("taskboard", "taskboard-postgres", {"username":"taskboard", "password":password,
       "database-url":f"postgresql+psycopg://taskboard:{password}@taskboard-postgres:5432/taskboard"})
subprocess.run(["kubectl","create","namespace","monitoring"], check=True)
secret("monitoring", "taskboard-grafana", {"admin-user":"archit", "admin-password":secrets.token_hex(24)})
PY
set -x
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --version 89.2.0 -n monitoring -f monitoring/prometheus-values.yaml -f monitoring/values-lab.yaml \
  --set grafana.admin.existingSecret=taskboard-grafana --wait --timeout 600s
kubectl apply -f ../grafana-dashboard.yaml
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --version 4.15.1 \
  -n ingress-nginx --create-namespace --set controller.service.type=ClusterIP \
  --set controller.resources.requests.cpu=100m --set controller.resources.requests.memory=128Mi \
  --set controller.resources.limits.memory=512Mi --wait --timeout 300s
helm lint helm/taskboard
helm upgrade --install taskboard ./helm/taskboard -n taskboard --create-namespace \
  -f helm/taskboard/values-dev.yaml --set ingress.host=localhost \
  --set "backend.image=$registry/archit-taskboard-lab/backend" --set "backend.tag=$tag" \
  --set "frontend.image=$registry/archit-taskboard-lab/frontend" --set "frontend.tag=$tag" \
  --wait --timeout 360s
kubectl -n taskboard get deployments,pods,svc,pvc,ingress,servicemonitors
kubectl -n taskboard exec deploy/taskboard-taskboard-backend -- id
kubectl -n taskboard exec deploy/taskboard-postgres -- \
  psql -U taskboard -d taskboard -c 'SELECT version();'
kubectl top nodes
helm list -A
