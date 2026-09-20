# Session 10 - Core Kubernetes Objects

Name: Archit Kulkarni  
Roll number: 24BCS10194

This folder keeps the supplied manifests grouped by exercise. Apply and clean up one scenario at a time so intentionally failing Pods do not interfere with later checks.

## Pod and lifecycle work

- `pod.yml`: standalone Nginx Pod. Validate with `kubectl get pod nginx-pod -o wide`, `kubectl logs nginx-pod`, then delete it.
- `hello.yml`: short BusyBox job with `restartPolicy: Never`; watch it move from creation to completion.
- `pod-lifecycle/`: running, pending, succeeded, failed, crash-loop, image-pull, readiness, liveness, startup, init-container, multi-container, and termination cases.

```bash
kubectl apply -f pod.yml
kubectl get pods -o wide
kubectl logs nginx-pod
kubectl delete -f pod.yml

kubectl get pods -w
kubectl apply -f hello.yml
kubectl logs hello-pod
kubectl delete -f hello.yml
```

An `ImagePullBackOff` creates an API object successfully because the API server persists the desired Pod specification first. The later image pull is a node-runtime operation; kubelet records the pull failure and retries with exponential backoff.

## Controllers and self-healing

`replicaset.yml` maintains the requested stateless replicas. Delete one selected pod and the ReplicaSet immediately creates another. `k8s-core-objects/statefulset.yml` demonstrates stable ordinal identities and claims for stateful workloads. `daemonset/node-agent-ds.yaml` schedules one host-agent Pod per eligible node.

```bash
kubectl apply -f replicaset.yml
kubectl get rs,pods -l app=nginx
kubectl apply -f k8s-core-objects/statefulset.yml
kubectl get sts,pods,pvc
kubectl apply -f daemonset/node-agent-ds.yaml
kubectl get ds,pods -o wide
```

## Deployment strategies and troubleshooting

`01-rolling-update/` uses `maxSurge: 1` and `maxUnavailable: 0`; `02-blue-green/` switches a Service selector between complete blue and green environments; `03-canary/` shares one Service across stable and canary replicas; `04-recreate/` deliberately terminates v1 before creating v2. The `troubleshooting/` manifests reproduce invalid image and selector mismatch failures.

```bash
kubectl apply -f 01-rolling-update/deployment-v1.yaml -f 01-rolling-update/service.yaml
kubectl apply -f 01-rolling-update/deployment-v2.yaml
kubectl rollout status deployment/app-rolling
kubectl rollout undo deployment/app-rolling
```

## Concepts used in this lab

`containerPort` describes an application port in a Pod; Service `targetPort` is the backend port; Service `port` is the virtual in-cluster port; `nodePort` is the externally reachable high port on every node. Labels are object metadata; selectors are matching queries used by Services and controllers.

For a three-replica Deployment, `maxSurge: 1` permits a fourth Pod during the update, while `maxUnavailable: 0` keeps all three requested endpoints available. Requests reserve scheduler capacity; limits cap runtime consumption. Memory units are binary for `Mi`/`Gi` and decimal for `M`/`G`.
