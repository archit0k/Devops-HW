#!/usr/bin/env bash
set -euo pipefail
set -x
k() { minikube kubectl -- -n homework9 "$@"; }
minikube status
minikube kubectl -- get nodes -o wide
minikube kubectl -- cluster-info
minikube kubectl -- -n kube-system get pods
minikube kubectl -- create namespace homework9
k create deployment kubernetes-bootcamp --image=nginx:1.27
k rollout status deployment/kubernetes-bootcamp --timeout=120s
k expose deployment kubernetes-bootcamp --type=NodePort --port=80
k get deploy,pods,svc -o wide
k scale deployment/kubernetes-bootcamp --replicas=4
k rollout status deployment/kubernetes-bootcamp --timeout=120s
k get pods
k set image deployment/kubernetes-bootcamp nginx=nginx:1.25
k rollout status deployment/kubernetes-bootcamp --timeout=120s
k get pods -o wide
k rollout history deployment/kubernetes-bootcamp
k rollout undo deployment/kubernetes-bootcamp
k rollout status deployment/kubernetes-bootcamp --timeout=120s
k run client --image=busybox:1.36 --restart=Never -- wget -qO- http://kubernetes-bootcamp
k wait --for=jsonpath='{.status.phase}'=Succeeded pod/client --timeout=120s
k logs client
minikube kubectl -- delete namespace homework9
