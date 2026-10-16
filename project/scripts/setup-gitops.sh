#!/usr/bin/env bash
set -euo pipefail
export PATH="/root/.minikube/cache/linux/amd64/v1.37.0:$PATH"
[[ $(kubectl config current-context) == minikube ]]
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
curl -fsSL --retry 3 -o /tmp/studyslot-argocd.yaml https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.5/manifests/install.yaml
sha256sum /tmp/studyslot-argocd.yaml
kubectl apply --server-side -n argocd -f /tmp/studyslot-argocd.yaml
# Only the private classroom UI uses HTTP behind a loopback port-forward.
# Keep login enabled and the Service as ClusterIP. No public exposure.
kubectl -n argocd patch configmap argocd-cmd-params-cm --type=merge -p '{"data":{"server.insecure":"true"}}'
kubectl -n argocd scale deployment argocd-dex-server argocd-notifications-controller argocd-applicationset-controller --replicas=0
kubectl -n argocd rollout restart deployment/argocd-server
kubectl -n argocd rollout status deployment/argocd-repo-server --timeout=300s
kubectl -n argocd rollout status deployment/argocd-server --timeout=300s
kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=300s
kubectl apply -f project/gitops/application.yaml
for attempt in $(seq 1 90); do
  state=$(kubectl -n argocd get application studyslot -o jsonpath='{.status.sync.status},{.status.health.status}')
  echo "$state"
  if [[ "$state" == Synced,Healthy ]]; then break; fi
  sleep 5
done
[[ "$state" == Synced,Healthy ]]
kubectl -n argocd get application studyslot
kubectl -n studyslot get deployments,pods,svc,ingress,pvc,hpa
