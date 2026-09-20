# Session 12 - ConfigMaps, Secrets, and Ingress

Name: Archit Kulkarni  
Roll number: 24BCS10194

## Configuration and secrets

`01-configmap/app-config.yaml` holds non-sensitive values. `02-secret/db-secret.yaml` holds Base64-encoded credentials. Base64 is transport encoding, not encryption; Kubernetes RBAC and an external secret manager protect access in production.

```bash
kubectl apply -f 01-configmap/app-config.yaml
kubectl get configmap
kubectl apply -f 02-secret/db-secret.yaml
kubectl get secret
kubectl get secret yatri-db-secret -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 --decode
```

Use `echo -n` before `base64`; plain `echo` appends a newline and changes the decoded password. Updating a ConfigMap does not restart Pods that read it through environment variables, so a rollout restart is needed for those Pods to receive new values.

## Ingress

An Ingress is a routing resource; an Ingress controller is the running software that watches it and performs the routing. Enable the NGINX controller before applying resources in `03-ingress/` or `04-full-demo/`.

```bash
minikube addons enable ingress
kubectl get pods -n ingress-nginx
kubectl apply -f 04-full-demo/configmap.yaml -f 04-full-demo/secret.yaml
kubectl apply -f 04-full-demo/backend.yaml -f 04-full-demo/frontend.yaml
kubectl apply -f 04-full-demo/ingress.yaml
kubectl get ingress
```

The full demo routes `/api` to the backend and `/` to the frontend. The `ingress-tls.yaml` example binds a TLS Secret so the controller can terminate HTTPS before forwarding traffic to ClusterIP services.

### Local observation

The ConfigMap and Secret were applied and listed successfully in the local cluster:

```text
NAME                         DATA   AGE
configmap/yatri-app-config   5      2s

NAME                     TYPE     DATA   AGE
secret/yatri-db-secret   Opaque   3      2s
```


## Secret-management flow

```text
Vault / cloud secret manager -> External Secrets Operator -> Kubernetes Secret -> Pod env or volume
```

The external manager remains the source of truth. The operator synchronizes short-lived Kubernetes Secrets, and workloads consume only the keys they need.
