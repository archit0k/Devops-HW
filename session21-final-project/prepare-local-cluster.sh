#!/usr/bin/env bash
set -euo pipefail
tag=25ef8e537db59c165ce4e9fe8f6d4c2e1d4e787f
start_args=(--driver=docker --memory=4096 --cpus=2)
if [[ $(id -u) = 0 ]]; then start_args+=(--force); fi
minikube start "${start_args[@]}"
minikube kubectl -- config use-context minikube
minikube addons enable metrics-server
minikube addons enable ingress
minikube image load "ghcr.io/archit0k/taskboard-backend:$tag"
minikube image load "ghcr.io/archit0k/taskboard-frontend:$tag"
minikube kubectl -- --context=minikube get nodes -o wide
minikube kubectl -- --context=minikube -n kube-system rollout status deployment/metrics-server --timeout=180s
minikube kubectl -- --context=minikube -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=180s
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community
helm show chart prometheus-community/kube-prometheus-stack --version 89.2.0
