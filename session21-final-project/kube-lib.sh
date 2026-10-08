#!/usr/bin/env bash
# Select only the two temporary classroom contexts used by this exercise.
lab_context=$(kubectl config current-context)
case "$lab_context" in
  minikube)
    # This matches Minikube 1.37 rather than using the separate EKS 1.35 CLI.
    local_kubectl=/root/.minikube/cache/linux/amd64/v1.37.0/kubectl
    test -x "$local_kubectl"
    export PATH="$(dirname "$local_kubectl"):$PATH"
    ;;
  taskboard-lab) ;;
  *) echo "Refusing to change the unrelated context: $lab_context" >&2; return 1 ;;
esac
helm() { command helm --kube-context="$lab_context" "$@"; }
