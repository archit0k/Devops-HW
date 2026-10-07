# Service FQDN

`web-service-clusterip.default.svc.cluster.local` names a Service, namespace, Kubernetes service zone and cluster domain. In the same namespace the short Service name works through DNS search paths. Across namespaces, use `service.namespace` or the full name. A Headless Service returns Pod addresses instead of one virtual ClusterIP, and a StatefulSet Pod can have a stable name such as `web-stateful-0.web-service-headless.default.svc.cluster.local`.

The [Services transcript](../evidence/commands.txt) includes actual short/full-name lookups, the ExternalName alias and the Headless Pod name.
