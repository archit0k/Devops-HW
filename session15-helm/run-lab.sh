#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"
minikube kubectl -- create namespace homework15 --dry-run=client -o yaml | minikube kubectl -- apply -f -
set -x
helm version --short
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami/nginx | head -n 5
scratch=$(mktemp -d)
helm create "$scratch/practice-chart"
helm lint "$scratch/practice-chart"
helm lint notes-chart
helm template notes-dev notes-chart -n homework15
helm install notes-dev notes-chart -n homework15 --wait --timeout 180s
helm list -n homework15
helm status notes-dev -n homework15
helm get values notes-dev -n homework15
helm get manifest notes-dev -n homework15
minikube kubectl -- -n homework15 get pods,svc,configmap
helm upgrade notes-dev notes-chart -n homework15 -f notes-chart/values-prod.yaml --wait --timeout 180s
helm history notes-dev -n homework15
minikube kubectl -- -n homework15 get pods -o wide
minikube kubectl -- -n homework15 exec deployment/notes-dev-deploy -- printenv ENVIRONMENT
helm upgrade notes-dev notes-chart -n homework15 -f notes-chart/values-prod.yaml --set image.tag=this-tag-does-not-exist
sleep 20
minikube kubectl -- -n homework15 get pods
minikube kubectl -- -n homework15 describe pods -l app=notes-dev
helm rollback notes-dev 2 -n homework15 --wait --timeout 180s
helm history notes-dev -n homework15
minikube kubectl -- -n homework15 get pods
helm uninstall notes-dev -n homework15
helm list -n homework15
minikube kubectl -- delete namespace homework15 --wait=true
