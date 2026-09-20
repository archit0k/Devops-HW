# Session 11 - Kubernetes Services and DNS

Name: Archit Kulkarni  
Roll number: 24BCS10194

The manifests cover ClusterIP, NodePort, LoadBalancer, ExternalName, Headless Services, manual endpoints, and DNS checks.

| Service | Main use |
| --- | --- |
| ClusterIP | Default private service for Pod-to-Pod traffic |
| NodePort | Development or bare-metal access through a node port |
| LoadBalancer | Cloud-provider external load balancer |
| ExternalName | DNS CNAME alias for an external FQDN |
| Headless | Direct Pod DNS records for stateful clients |

```bash
kubectl apply -f 01-clusterip/
kubectl get svc,endpoints
kubectl apply -f 02-nodeport/
minikube service <nodeport-service-name> --url
kubectl apply -f 05-headless/
kubectl exec -it <client-pod> -- nslookup <headless-service>
```

A normal Service selects matching labels and Kubernetes writes EndpointSlices automatically. A selector-less Service has no automatic backend discovery; its Endpoint/EndpointSlice must be maintained manually. A StatefulSet gives stable names such as `db-0`, whereas Deployment Pods are replaceable and get new generated names.

Useful DNS format: `<service>.<namespace>.svc.cluster.local`. On local Minikube with the Docker driver, `minikube tunnel` is needed for a reachable LoadBalancer address; NodePort access can use `minikube service ... --url`.
