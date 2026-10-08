#!/usr/bin/env bash
set -euo pipefail
tag=${TASKBOARD_TAG:-09c8dec70b4652578823881ce4c51e73bfd945a4}
start_args=(--driver=docker --memory=4096 --cpus=4)
if [[ $(id -u) = 0 ]]; then start_args+=(--force); fi
minikube start "${start_args[@]}"
# An existing Docker profile can retain its old limits after minikube start.
docker update --memory 4g --memory-swap 6g --cpus 4 minikube
minikube kubectl -- config use-context minikube
minikube addons enable metrics-server
minikube addons enable ingress
for app in backend frontend; do
  image="ghcr.io/archit0k/taskboard-$app:$tag"
  if ! minikube image ls | grep -Fxq "$image"; then minikube image load "$image"; fi
done
minikube kubectl -- --context=minikube get nodes -o wide
minikube kubectl -- --context=minikube -n kube-system rollout status deployment/metrics-server --timeout=180s
minikube kubectl -- --context=minikube -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=180s
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community
helm show chart prometheus-community/kube-prometheus-stack --version 89.2.0
