# Session 20 — Monitoring, observability and GitOps

Archit Kulkarni | 24BCS10194 | Section A

| Task | Files and result |
| --- | --- |
| Monitoring | [monitoring/](monitoring/): Prometheus/Grafana, CPU/memory/health dashboard and firing/recovery alert test |
| Observability | Notes below compare metrics, logs and traces, with commands and investigation order |
| GitOps | [app/](app/) and [Application](argocd-application.yaml): Git change from two to three replicas, then automatic drift correction |

## Prometheus and Grafana

The [Compose setup](monitoring/compose.yaml) runs Prometheus 3.5.0 and Grafana 12.1.1. Prometheus scrapes itself and Grafana every five seconds. Grafana connects to Prometheus through its Compose service name.

```bash
docker compose -f monitoring/compose.yaml up -d
docker compose -f monitoring/compose.yaml ps
curl 'http://localhost:9090/api/v1/query?query=up'
docker compose -f monitoring/compose.yaml logs --tail=15
docker compose -f monitoring/compose.yaml down
```

The dashboard shows target health (`up`), process memory and CPU rate. Both ports bind to `127.0.0.1`, with anonymous read-only dashboard access. [TargetDown](monitoring/alerts.yml) fires after a target is unreachable for ten seconds.

![Live Grafana dashboard](evidence/grafana.jpg)

[Monitoring API/health/log output](evidence/monitoring.txt) and the [alert test](evidence/alert.txt) record the values. The test stops Grafana, waits for `TargetDown` to enter `firing`, restarts Grafana and checks recovery.

## GitOps mini project

`app/` contains the namespace, Nginx Deployment and Service. The [Argo CD Application](argocd-application.yaml) stays **outside** that watched directory and points to this repository's real `main` branch.

1. Commit `f68b99b` defined two replicas. Argo CD read Git and created them in namespace `homework20`.
2. Commit `d7ec068` changed the Git manifest to three replicas. Argo CD automatically applied that change.
3. The lab ran `kubectl scale ... --replicas=1`. Git still specified three, so Argo CD self-healed back to three. Rollout and HTTP checks then passed.
4. The Application and the runner's disposable kind cluster were removed.

The [GitOps run](https://github.com/archit0k/Devops-HW/actions/runs/37657659611) and [command output](evidence/commands.txt) show the replica changes: 2 → 3 → 1 → 3. GitOps ran on a GitHub-hosted Kind cluster; monitoring ran locally in Ubuntu WSL. To repeat the change, start with two replicas in Git, then commit three.

## Viva notes

Metrics are numerical samples, logs record events, and traces connect the steps of a request. This lab uses Prometheus/Grafana for metrics and `docker compose logs` or `kubectl logs` for logs. Jaeger and Tempo are examples of tracing backends.

1. Monitoring checks known signals/conditions; observability lets me investigate why an unexpected problem happened using system outputs.
2. Metrics are numerical time series, logs are event records, and traces follow a request through multiple components. A trace/span ID can connect these views.
3. Prometheus pulls metrics, stores time series and evaluates PromQL/rules.
4. Grafana visualizes data from sources such as Prometheus; it is not the metrics database here.
5. GitOps uses versioned desired state and a reconciler to apply it.
6. Git is the source of truth because reviewed commits define what should run and preserve change history.
7. Argo CD compares Git manifests with the cluster and synchronizes differences.
8. Desired state is the Git specification, such as three replicas.
9. Actual state is what Kubernetes currently has, such as one replica after a manual change.
10. Reconciliation compares the two and moves actual state toward desired state.
11. Self-healing restores manual cluster drift when enabled. It is not the same as a Deployment replacing one failed Pod.
12. Changing two to three in Git causes Argo CD to update the Deployment; Kubernetes creates the additional Pod.

For an incident I would check target health, CPU/memory and request latency, then application logs and any available traces.

![Manual replica drift restored by Argo CD in the saved runner output](evidence/gitops-self-heal.jpg)
