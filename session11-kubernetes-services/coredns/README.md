# CoreDNS

[Back to Session 11](../README.md)

CoreDNS is the cluster's DNS server and lets Pods find Services by name instead of hardcoding changing addresses. The `kubernetes` plugin answers for the cluster zone; `forward` sends external queries to upstream resolvers; `cache` avoids repeated work. Pods normally use the kube-dns Service IP from their resolver configuration.

```bash
kubectl -n kube-system get deployment coredns
kubectl -n kube-system get configmap coredns -o yaml
kubectl -n kube-system logs deployment/coredns --tail=20
kubectl exec lab-client -- nslookup web-service-clusterip.default.svc.cluster.local
```

Check the requested Service/namespace and Endpoints first. If multiple correct names fail, inspect CoreDNS readiness, logs and upstream connectivity. An ExternalName record supplies a CNAME; it does not create a proxy or rewrite an HTTP Host header. The cluster domain can be configured differently from `cluster.local`.

For an internal query, Pod resolver → kube-dns Service → CoreDNS `kubernetes` plugin → Service/Pod record. For an external name, CoreDNS forwards the query upstream and returns the answer. The Service and CoreDNS checks are included in the [runner output](../evidence/runner/commands.txt).
