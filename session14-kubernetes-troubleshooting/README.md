# Session 14 - Kubernetes Troubleshooting

Archit Kulkarni | 24BCS10194 | Section A

The mini project starts with a two-replica Nginx Deployment and ClusterIP Service. The lab deliberately breaks one thing at a time, checks the cause, fixes it, and repeats the request.

## Commands and evidence

Run `bash run-lab.sh` from Ubuntu with Minikube running. The complete local commands and real output are in [evidence/lab.txt](evidence/lab.txt). The runner version uses an isolated kind cluster; it is not a screenshot of the laptop's Minikube cluster.

| Problem | Check | Fix and verification |
| --- | --- | --- |
| Invalid Nginx tag | `get pod`, `describe pod`, events | Set image to `nginx:1.27`; wait for Ready |
| Service has no endpoints | Compare selector with Pod labels and EndpointSlices | Restore `app: troubleshooting-app`; repeat HTTP request |
| CrashLoopBackOff | Current/previous logs and container exit code | Replace the failing startup command; wait for Ready |
| Pending Pod | Scheduler events show an impossible 9Gi request | Reduce request to 32Mi/25m; wait for rollout |
| ContainerCreating | `describe` reports missing ConfigMap volume | Create `required-settings`; read `/settings/mode` |
| DNS lookup fails | Check Service name, namespace and full DNS name | Use `troubleshooting-service.homework14.svc.cluster.local` |
| Connection to port 81 fails | Compare Service `port` and container `targetPort` | Request port 80; check the actual HTTP response |

Other commands exercised: `kubectl logs`, `exec`, `get events --sort-by=.metadata.creationTimestamp`, `explain pod.spec.containers`, `top pods`, and `get pods,svc -o wide`. `top` needs metrics-server; the local cluster has it.

## Short answers

1. Start with `get pods -o wide`, then `describe` and logs. A status tells me where to look, not the complete cause.
2. CrashLoopBackOff means a container repeatedly exits and Kubernetes is delaying restarts. Check its command, exit code and previous logs.
3. ErrImagePull is a failed pull attempt; ImagePullBackOff is the retry delay. A bad tag, registry permission or DNS failure can all cause it.
4. Pending usually needs scheduler events: resources, node selectors, taints or unbound claims.
5. ContainerCreating can be blocked by a missing Secret/ConfigMap, a volume mount or runtime networking.
6. A healthy Deployment does not prove its Service is correct. Selectors, endpoints and ports still need checking.
7. Use the namespace-qualified Service name when the client is in another namespace. Check CoreDNS only after checking the name.
8. ConfigMap/Secret names and keys must match the Pod references. Environment changes need a new Pod; volume updates behave differently.
9. Logs explain application errors; events explain scheduling, pulling and mounting problems. `describe` brings the latter together.
10. A fix is complete only after the Pod is healthy and the original client request works again.

The first local attempt also hit a real laptop DNS problem while pulling a valid image. Valid images were loaded into Minikube's cache, and the lab was rerun. Network failures are not evidence that an image tag is invalid.

The script removes only its `homework14` namespace at the end.

The [clean runner recheck](https://github.com/archit0k/Devops-HW/actions/runs/37660525939) passed with pipeline failure propagation enabled. [Runner output](evidence/runner/commands.txt) preserves the independent break/fix tests.
