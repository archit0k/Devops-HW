#!/usr/bin/env bash
set -euo pipefail
tag=${1:?Pass a tested image SHA}
[[ "$tag" =~ ^[0-9a-f]{40}$ ]]
[[ $(kubectl config current-context) == arn:aws:eks:*:cluster/archit-studyslot ]]
kubectl get nodes -o wide
kubectl apply -f project/k8s/storageclass.yaml
python3 project/scripts/bootstrap-secret.py
python3 project/scripts/registry-secret.py
bash project/scripts/setup-monitoring.sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# Isolated classroom controller. ClusterIP only, no public load balancer.
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --version 4.15.1 \
  -n ingress-nginx --create-namespace --set controller.service.type=ClusterIP --wait --timeout 300s
helm upgrade --install studyslot project/helm/studyslot -n studyslot --set "imageTag=$tag" \
  --set database.storageClass=studyslot-gp3 --set ingress.host=localhost \
  --set 'imagePullSecrets[0].name=ghcr' --set monitoring.serviceMonitor=true --wait --timeout 300s
bash project/scripts/verify-aws.sh
