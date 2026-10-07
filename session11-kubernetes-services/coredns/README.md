# CoreDNS

CoreDNS answers cluster DNS queries. The `kubernetes` plugin serves the cluster zone; `forward` handles external names using upstream resolvers; `cache` reduces repeated lookups. Pods normally point at the kube-dns Service address.

```bash
kubectl -n kube-system get deployment coredns
kubectl -n kube-system get configmap coredns -o yaml
kubectl -n kube-system logs deployment/coredns --tail=20
kubectl exec lab-client -- nslookup web-service-clusterip.default.svc.cluster.local
```

Check the requested Service/namespace and Endpoints first. If multiple correct names fail, inspect CoreDNS readiness, logs and upstream connectivity. An ExternalName record supplies a CNAME; it does not create a proxy or rewrite an HTTP Host header. The cluster domain can be configured differently from `cluster.local`.
