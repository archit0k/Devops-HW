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
minikube service web-service-nodeport --url
kubectl apply -f 05-headless/
kubectl exec -it headless-dns-client -- nslookup web-service-headless
```

A normal Service selects matching labels and Kubernetes writes EndpointSlices automatically. A selector-less Service has no automatic backend discovery; its Endpoint/EndpointSlice must be maintained manually. A StatefulSet gives stable names such as `db-0`, whereas Deployment Pods are replaceable and get new generated names.

Useful DNS format: `<service>.<namespace>.svc.cluster.local`. On local Minikube with the Docker driver, `minikube tunnel` is needed for a reachable LoadBalancer address; NodePort access can use `minikube service ... --url`.

## Actual checks

The [successful Service/DNS run](https://github.com/archit0k/Devops-HW/actions/runs/37664009319) checks ClusterIP HTTP, NodePort HTTP through the real node IP, LoadBalancer internal HTTP, ExternalName CNAME resolution, headless Pod records, EndpointSlices and CoreDNS configuration. [Full output](evidence/runner/commands.txt) is saved beside the manifests.

The instructor's old ExternalName destination no longer resolved during the check, so the example uses `example.com`; the Service still demonstrates a CNAME rather than proxying traffic. [FQDN notes](fqdn/README.md) and [CoreDNS notes](coredns/README.md) explain both lookup paths.

External LoadBalancer access was separately verified on local Minikube with `minikube tunnel`: external IP `127.0.0.1`, two ready Pods, and an actual Nginx HTTP response. [Tunnel output and cleanup](evidence/loadbalancer-tunnel.txt) records that check; a pending external address on a plain kind cluster was not treated as external access.
