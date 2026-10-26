# Service FQDN

[Back to Session 11](../README.md)

FQDN means fully qualified domain name. It includes enough labels to identify a name without relying on the caller's namespace search path.

`web-service-clusterip.default.svc.cluster.local` names a Service, namespace, Kubernetes service zone and cluster domain. In the same namespace the short Service name works through DNS search paths. Across namespaces, use `service.namespace` or the full name. A Headless Service returns Pod addresses instead of one virtual ClusterIP, and a StatefulSet Pod can have a stable name such as `web-stateful-0.web-service-headless.default.svc.cluster.local`.

The [Services transcript](../evidence/commands.txt) includes actual short/full-name lookups, the ExternalName alias and the Headless Pod name.

```bash
kubectl exec lab-client -- nslookup web-service-clusterip
kubectl exec lab-client -- nslookup web-service-clusterip.default.svc.cluster.local
```

A client in a different namespace should use `web-service-clusterip.default` or the full name. A successful DNS answer confirms name resolution; an HTTP request is still needed to verify the application port.
