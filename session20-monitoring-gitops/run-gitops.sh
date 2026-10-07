#!/usr/bin/env bash
set -euo pipefail
set -x
kubectl create namespace argocd
curl -fsSL --retry 3 -o /tmp/argocd-install.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sha256sum /tmp/argocd-install.yaml
kubectl apply -n argocd --server-side -f /tmp/argocd-install.yaml
kubectl -n argocd rollout status deployment/argocd-repo-server --timeout=300s
kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=300s
kubectl -n argocd get pods
kubectl apply -f session20-monitoring-gitops/argocd-application.yaml
for attempt in {1..60}; do
  ready=$(kubectl -n homework20 get deployment homework20-web -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)
  [[ "$ready" == 2 ]] && break
  sleep 5
done
test "$ready" = 2
kubectl -n argocd get application homework20
kubectl -n homework20 get all
echo 'INITIAL TWO REPLICAS VERIFIED; waiting for the Git commit changing replicas to three.'
for attempt in {1..150}; do
  replicas=$(kubectl -n homework20 get deployment homework20-web -o jsonpath='{.spec.replicas}')
  [[ "$replicas" == 3 ]] && break
  # Request a Git refresh only. Argo CD still performs the automatic synchronization.
  kubectl -n argocd annotate application homework20 argocd.argoproj.io/refresh=normal --overwrite
  sleep 5
done
test "$replicas" = 3
kubectl -n homework20 rollout status deployment/homework20-web --timeout=180s
kubectl -n homework20 get deployment,pods
kubectl -n homework20 scale deployment homework20-web --replicas=1
kubectl -n homework20 get deployment homework20-web
for attempt in {1..40}; do
  replicas=$(kubectl -n homework20 get deployment homework20-web -o jsonpath='{.spec.replicas}')
  [[ "$replicas" == 3 ]] && break
  sleep 3
done
test "$replicas" = 3
kubectl -n homework20 rollout status deployment/homework20-web --timeout=120s
kubectl -n argocd get application homework20 -o yaml
kubectl -n homework20 get all
kubectl -n homework20 run client --image=busybox:1.36 --restart=Never -- sh -c 'wget -qO- http://homework20-web'
kubectl -n homework20 wait --for=jsonpath='{.status.phase}'=Succeeded pod/client --timeout=90s
kubectl -n homework20 logs client
kubectl -n homework20 logs deployment/homework20-web --tail=12
kubectl delete -f session20-monitoring-gitops/argocd-application.yaml --wait=true
kubectl -n argocd get applications
