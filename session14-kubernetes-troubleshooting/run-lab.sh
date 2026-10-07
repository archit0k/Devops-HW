#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
k() { minikube kubectl -- -n homework14 "$@"; }
minikube kubectl -- create namespace homework14 --dry-run=client -o yaml | minikube kubectl -- apply -f -
set -x
k apply -f mini-project/deployment.yaml -f mini-project/service.yaml
k rollout status deployment/troubleshooting-app --timeout=180s
k run client --image=busybox:1.36 --restart=Never -- sleep 3600
k wait --for=condition=Ready pod/client --timeout=180s
k get pods,svc -o wide
k describe deployment troubleshooting-app
k logs deployment/troubleshooting-app --tail=8
k exec client -- nslookup troubleshooting-service.homework14.svc.cluster.local
k exec client -- wget -qO- http://troubleshooting-service
k explain pod.spec.containers
k top pods || true
k get events --sort-by=.metadata.creationTimestamp

# Image-pull failure: keep the broken object long enough to inspect it.
k apply -f mini-project/broken-pod.yaml
for attempt in {1..20}; do
  reason=$(k get pod project-broken-pod -o jsonpath='{.status.containerStatuses[0].state.waiting.reason}')
  [[ "$reason" == "ImagePullBackOff" ]] && break
  sleep 3
done
k get pod project-broken-pod
k describe pod project-broken-pod
k set image pod/project-broken-pod app=nginx:1.27
k wait --for=condition=Ready pod/project-broken-pod --timeout=180s
k get pod project-broken-pod

# Selector mismatch: endpoints disappear even though the pods are healthy.
k patch svc troubleshooting-service -p '{"spec":{"selector":{"app":"wrong-app"}}}'
k get endpointslice -l kubernetes.io/service-name=troubleshooting-service
k get pods --show-labels
k exec client -- timeout 5 wget -qO- http://troubleshooting-service || true
k patch svc troubleshooting-service -p '{"spec":{"selector":{"app":"troubleshooting-app"}}}'
k get endpointslice -l kubernetes.io/service-name=troubleshooting-service
k exec client -- wget -qO- http://troubleshooting-service

# CrashLoopBackOff, then replace the immutable command with a healthy one.
k run crash --image=busybox:1.36 --restart=Always -- sh -c 'echo missing-startup-config; exit 1'
sleep 12
k get pod crash
k logs crash --previous || k logs crash
k describe pod crash
k delete pod crash --wait=true
k run crash --image=busybox:1.36 --restart=Always -- sleep 3600
k wait --for=condition=Ready pod/crash --timeout=120s

# Unschedulable resource request, then correct it in the workload template.
k create deployment pending --image=nginx:1.27
k set resources deployment/pending --requests=memory=9Gi
sleep 5
k get pods -l app=pending
k describe pods -l app=pending
k set resources deployment/pending --requests=memory=32Mi,cpu=25m
k rollout status deployment/pending --timeout=120s

# Missing ConfigMap keeps a mount in ContainerCreating; create the required key.
k run missing-config --image=nginx:1.27 --restart=Never --overrides='{"spec":{"containers":[{"name":"missing-config","image":"nginx:1.27","volumeMounts":[{"name":"settings","mountPath":"/settings"}]}],"volumes":[{"name":"settings","configMap":{"name":"required-settings"}}]}}'
sleep 8
k get pod missing-config
k describe pod missing-config
k create configmap required-settings --from-literal=mode=classroom
k wait --for=condition=Ready pod/missing-config --timeout=120s
k exec missing-config -- cat /settings/mode

# Wrong namespace DNS and wrong port; compare with the actual working values.
k exec client -- nslookup troubleshooting-service.wrong-namespace.svc.cluster.local || true
k exec client -- nslookup troubleshooting-service.homework14.svc.cluster.local
k exec client -- timeout 5 wget -qO- http://troubleshooting-service:81 || true
k get service troubleshooting-service -o yaml
k exec client -- wget -qO- http://troubleshooting-service:80
k get pods,svc -o wide
minikube kubectl -- delete namespace homework14 --wait=true
