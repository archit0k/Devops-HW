# StudySlot evidence

Archit Kulkarni · 24BCS10194 · Section A · Recorded 16 October 2026

Screenshots are browser captures of the actual lab. Command-output screenshots display saved stdout; their linked `.txt` records contain the commands, timestamps and exit codes. Earlier failed attempts remain available below so they are not confused with passing checks.

| Module | Source and result | Screenshots / recording |
| --- | --- | --- |
| M1 Application | [API](../backend/app/), [migration](../backend/alembic/versions/001_bookings.py), [frontend](../frontend/), [real PostgreSQL CRUD/conflict check](kubernetes-final.txt) | [Desktop](desktop-browser.jpg), [mobile](mobile-browser.jpg), [Ingress application](app-ingress.jpg) |
| M2 Testing | [16 tests](../backend/tests/test_bookings.py), [pytest configuration](../backend/pytest.ini), [passing pytest](pytest-final.txt), [Ruff/Bandit/dependency checks](tests-final.txt) | [All tests passing](pytest-output.jpg) |
| M3 Git/GitHub | [Public repository](https://github.com/archit0k/Devops-HW), [history](https://github.com/archit0k/Devops-HW/commits/main/), [12 recent commits](git-history.txt), [ignore rules](../../.gitignore) | [Commit history](commit-history.jpg) |
| M4 Docker | [Backend Dockerfile](../backend/Dockerfile), [multi-stage frontend](../frontend/Dockerfile), [Compose](../docker-compose.yml), [build/health/non-root/integration output](compose-final.txt) | [Compose output and UIDs](compose-output.jpg), [browser](compose-browser.jpg) |
| M5 CI/CD | [Workflow](../../.github/workflows/studyslot.yml), [six-job green push](https://github.com/archit0k/Devops-HW/actions/runs/38894261034), [second six-job green run](https://github.com/archit0k/Devops-HW/actions/runs/38894715964), [namespace-only EKS CD log](eks-cd-final.txt) | [Green pipeline](pipeline-final.jpg), SHA-tagged public [backend](ghcr-backend.jpg)/[frontend](ghcr-frontend.jpg) packages, [video](../../demo/walkthrough.mp4) |
| M6 DevSecOps | [Security explanation](../security/README.md), Trivy [backend](ci-d410e13/scans/backend.txt)/[frontend](ci-d410e13/scans/frontend.txt) artifacts; HIGH/CRITICAL findings fail the pipeline | Trivy [backend](trivy-backend.jpg)/[frontend](trivy-frontend.jpg) output |
| M7 Terraform/AWS | [Terraform source](../terraform/), [init](terraform-init-final.txt), [validate](terraform-validate-final.txt), [26-resource plan](terraform-plan-ready.txt), [apply](terraform-apply-final.txt), [destroy](terraform-destroy-final.txt), [leftover checks](cloud-cleanup-final.txt) | [Init](terraform-init-output.jpg), [plan](terraform-plan-output.jpg), [apply](terraform-apply-output.jpg), [VPC](aws-vpc.jpg)/[two-zone map](aws-vpc-map.jpg), [EKS Active](aws-eks.jpg), [destroy complete](terraform-destroy-output.jpg) |
| M8 Kubernetes/Helm | [Namespace](../k8s/namespace.yaml), [complete chart](../helm/studyslot/), [local checks](kubernetes-final.txt), [AWS Ingress/CRUD/non-root/migration checks](aws-deployment/aws-bootstrap.txt), [PVC persistence](storage-restart.txt) | [Running Pods, Services, PVC, Ingress, HPA and Helm releases](kubernetes-pods-services.jpg), [Ingress app](app-ingress.jpg), [storage restart](storage-output.jpg) |
| M9 Observability | [Monitoring values](../monitoring/values.yaml), [dashboard](../monitoring/dashboard.yaml), [curl metrics output](metrics-curl.txt), [target and PromQL checks](kubernetes-final.txt) | [Metrics output](metrics-output.jpg), [two targets UP](prometheus-targets.jpg), [populated Grafana](grafana-live.jpg) |
| M10 Presentation/docs | [Full root README](../../README.md), [project documentation](../README.md), [demo folder](../../demo/README.md), [video format/duration check](video-check.txt) | [Ten-slide PPTX](../../demo/presentation.pptx), [captioned MP4](../../demo/walkthrough.mp4) |

## GitOps

The [Application](../gitops/application.yaml) follows the chart and [pinned tested image values](../gitops/values-local.yaml). The recorded [configuration commit](https://github.com/archit0k/Devops-HW/commit/1c56857fa3de1eaa43eb8e17c285361d171dae30) changed `demoRevision` to `booking-demo`, which updated the ConfigMap/Pod annotation and rolled out the backend. [Argo CD shows Synced/Healthy](argocd-synced.jpg). Backend replica drift is ignored because the HPA owns scaling.

## Cloud access and cleanup

The [bootstrap run](https://github.com/archit0k/Devops-HW/actions/runs/38893003011) succeeded on real EKS with two Ready worker nodes. The [namespace access record](terraform-namespace-access.txt) confirms removal of cluster-admin access; a [small Role](../k8s/ci-monitoring-rbac.yaml) covers the custom ServiceMonitor resource that AWS's built-in Edit policy omits.

Cloud CD was disabled before teardown. The [Kubernetes cleanup run](https://github.com/archit0k/Devops-HW/actions/runs/38896048655) removed the application and PVC; [stdout](aws-kubernetes-cleanup.txt) and [remaining worker-volume check](aws-volumes-before-destroy.txt) are saved. Terraform then destroyed all 26 managed resources. [Read-only checks](cloud-cleanup-final.txt) verify that the StudySlot cluster, VPC, active workers, recorded volumes, IAM roles, OIDC provider and Terraform state entries are gone. Other account resources were not changed.

The [local shutdown record](local-shutdown.txt) confirms that Minikube, Docker and containerd were stopped. The stopped container's original two-CPU/2-GiB limits were restored. The local PVC and ignored SQL backup are preserved; no demo is silently left running.

## Earlier attempts and historical records

- [Existing Compose volume password mismatch](compose-existing-volume.txt): that older volume was preserved; `compose-final.txt` uses a separate verification stack.
- [Initial Argo/Helm ownership race](local-install.txt), followed by [successful adoption](local-helm-adopt.txt).
- [Port-forward rollover after a backend update](kubernetes-forward-rollout.txt), followed by the passing `kubernetes-final.txt` check.
- [Initial plan command argument issue](terraform-plan-final.txt), followed by `terraform-plan-ready.txt`.
- [Provider startup timeout](terraform-oidc-apply.txt), followed by [successful OIDC update](terraform-oidc-apply-retry.txt).
- [Provider-cache checksum attempt](terraform-restrict-access.txt), followed by [successful restriction](terraform-restrict-access-final.txt).

Older October 7 project records are retained for history. The module table above points to the final October 16 records. No submission form was sent.
