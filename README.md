# DevOps Homework - Archit Kulkarni

Roll number: **24BCS10194**
Section: A

Each assignment is kept in its own folder. Commands, implementation files, Dockerfiles, and verification notes live beside the relevant exercise.

| Session | Assignment README | Work |
| --- | --- | --- |
| 1–2 | [Linux Fundamentals](01-linux-fundamentals/README.md) | Links, users, journald and command practice |
| 3 | [Shell Scripting](02-shell-scripting/README.md) | System-information script |
| 4 | [Networking](03-networking-fundamentals/README.md) | Networking commands and explanations |
| 5 | [Git and GitHub](04-git-github/README.md) | Commits, branches and cherry-pick |
| 6 | [Docker Fundamentals](05-docker-hello-apps/README.md) | Six Hello World applications |
| 7 | [Docker Images](06-docker-multistage/README.md) | Multi-stage build on port 8080 |
| 8 | [Docker Networking](07-docker-networking-volumes/README.md) | Networks, host networking, bind mounts and overlays |
| 9 | [Kubernetes Fundamentals](session9-k8s/README.md) | Minikube and cluster architecture |
| 10 | [Pods, ReplicaSets and Deployments](session10-k8s-core-objects/README.md) | Lifecycle, controllers and four rollout strategies |
| 11 | [Networking and Services](session11-kubernetes-services/README.md) | Five Service types and DNS |
| 12 | [Ingress, ConfigMaps and Secrets](session12-ingress-configmaps-secrets/README.md) | Configuration injection and HTTP routing |
| 13 | [Storage and Scaling](session13-kubernetes-storage-and-scaling/README.md) | Volumes, PVCs, probes and HPA |
| 14 | [Kubernetes Troubleshooting](session14-kubernetes-troubleshooting/README.md) | Diagnose, break, fix and verify |
| 15 | [Helm](session15-helm/README.md) | Chart install, upgrade and rollback |
| 16 | [GitHub Actions](session16-github-actions/README.md) | Calculator CI/CD exercise |
| 17 | [DevSecOps](session17-devsecops/README.md) | Tests, scans, gates, registry and Kubernetes |
| 18 | [Terraform and IaC](session18-terraform/README.md) | S3 lifecycle and AWS service notes |
| 19 | [Cloud and Terraform](session19-cloud-terraform/README.md) | VPC, subnet, Security Group, EC2 and S3 |
| 20 | [Monitoring, Observability and GitOps](session20-monitoring-gitops/README.md) | Prometheus, Grafana and Argo CD |
| 21 | [TaskBoard walkthrough and troubleshooting](session21-final-project/README.md) | Instructor's application, commands and results |
| Capstone | [StudySlot](project/README.md) | Original booking app, CI/CD, Terraform/EKS, Helm, GitOps and monitoring |

## Verification

The labs use Docker Engine in Ubuntu WSL; Docker Desktop is not needed. Local Kubernetes commands use a kubectl version matched to Minikube. Sessions 1–20 have execution records and screenshots linked from their READMEs. Session 21's classroom walkthrough is also recorded: application and Swagger CRUD, PostgreSQL persistence, Ingress, real HPA scaling, Prometheus/Grafana and both troubleshooting cases. Its test/build/scan/publish/deploy pipeline passed. The EKS Terraform apply and destroy succeeded, but AWS application access was rejected for the root account; the README does not claim a successful application deployment on AWS. The classroom Kubernetes checks ran on Minikube instead.

The separate [StudySlot capstone](project/README.md) has its own application and deployment evidence. It is not the Session 21 assignment. Its EKS application checks succeeded using the temporary GitHub OIDC role. Assignment verification records remain linked from the individual READMEs.

## StudySlot capstone

StudySlot lets students reserve, change and cancel a one-hour study-room booking. Room-capacity checks and a PostgreSQL unique constraint prevent invalid or overlapping bookings, including concurrent requests. It uses only disposable classroom data and has no user authentication.

```text
Browser → Ingress → React/Nginx (/) → FastAPI (/api) → PostgreSQL/PVC
                                      │ /metrics
                                      ▼
                                  Prometheus → Grafana
main push → tests/audits → Docker/Trivy → GHCR SHA tags → Helm/Kind → EKS
Git chart + pinned tested image → Argo CD → local Kubernetes
Terraform → AWS VPC + two public subnets + EKS + two workers
```

The stack is Python 3.14/FastAPI, SQLAlchemy/Alembic, PostgreSQL 17, React/Vite, Nginx, Docker Compose, GitHub Actions, Trivy, Terraform, Kubernetes, Helm, Argo CD, Prometheus and Grafana. The [project README](project/README.md) has API details and troubleshooting; the [evidence index](project/evidence/README.md) maps all ten grading modules to source, logs and screenshots. The [demo folder](demo/README.md) contains the ten-slide PPTX and captioned MP4 walkthrough.

### Run locally

```bash
cd project
cp .env.example .env
# Set a local POSTGRES_PASSWORD in the ignored .env file.
docker compose up --build -d
docker compose ps -a
```

Open [localhost:3000](http://localhost:3000) and [Swagger](http://localhost:8000/docs). The migration service waits for PostgreSQL before the API starts. Both application containers run as non-root users; PostgreSQL has no published host port. `docker compose stop` stops the stack and preserves the volume. A reused volume keeps its original password; do not delete it just to change `.env`.

### Tests, CI/CD and security

Run `pytest -v` in `project/backend/` after installing `requirements-dev.txt`. Sixteen tests use an isolated test database. The separate HTTP integration check exercises real PostgreSQL CRUD and simultaneous booking requests, expecting 201/409. Ruff, Bandit, Python/Node dependency audits and a full-history Gitleaks scan run in the pipeline.

Every main push triggers [studyslot.yml](.github/workflows/studyslot.yml). Both final Docker images are built, scanned with Trivy and checked through Compose. Any HIGH/CRITICAL finding fails the image gate. A clean result means no matching advisory was found at that time, not that the app is vulnerability-free. Successful images are published to GHCR with full commit-SHA tags; the exact scanned images are tested with Helm in an isolated Kind cluster before the optional EKS deployment. [Security notes](project/security/README.md).

### AWS infrastructure and cleanup

With the temporary `devops-homework` profile configured, run from the repository root:

```bash
terraform -chdir=project/terraform init
terraform -chdir=project/terraform validate
bash project/scripts/terraform-lab.sh plan
bash project/scripts/terraform-lab.sh apply
# Bootstrap the cluster through the AWS setup workflow, then restrict access:
bash project/scripts/terraform-lab.sh restrict
```

Terraform creates the VPC, public subnets in two zones, internet gateway/routes, EKS 1.35, two `t3.medium` workers, EBS CSI/Pod Identity and Metrics Server. The application uses a ClusterIP Ingress controller; no NAT gateway, RDS or public application LoadBalancer is created. GitHub OIDC trusts only this repository's immutable IDs and main branch. Initial cluster-only administration is removed after bootstrap; deployment access is namespace-only, with a small ServiceMonitor Role. No IAM user or permanent key is created. [Infrastructure details](project/terraform/README.md).

Disable `ENABLE_EKS_CD` before cleanup, dispatch the AWS workflow's `cleanup` action to delete the application/PVC while EBS CSI still runs, then run `bash project/scripts/terraform-lab.sh destroy`. Keep ignored state until teardown is confirmed. The spending cap is $30, including the earlier homework labs; credits do not make resources free indefinitely.

### Helm, GitOps and monitoring

The [chart](project/helm/studyslot/) defines two frontend replicas, a backend HPA (2–4 replicas), probes, ClusterIP Services, `/` and `/api` Ingress routes and PostgreSQL on a PVC. For local verification, load the tested SHA images and run `project/scripts/prepare-local.sh <SHA>`, then `project/scripts/setup-gitops.sh` and `project/scripts/forward-local.sh`. Stop Compose first to free ports. The combined local monitoring/GitOps lab needs about 5 GiB RAM and six CPUs.

Argo CD reads the chart and pinned image tag from Git, with auto-sync and self-healing. The recorded `demoRevision` change caused a real backend rollout and reached Synced/Healthy. Argo leaves backend replica scaling to the HPA. Port 3000 forwards the Ingress controller; backend 8000, Prometheus 9090, Grafana 3001 and Argo 8081 bind only to loopback.

The [monitoring values](project/monitoring/values.yaml) install Prometheus/Grafana. A ServiceMonitor scrapes backend `/metrics`; the [dashboard](project/monitoring/dashboard.yaml) shows request counts/rates, target health, replicas, CPU, p95 latency and errors. Runtime passwords are kept in Secrets, not Git. [Targets screenshot](project/evidence/prometheus-targets.jpg) and [populated Grafana](project/evidence/grafana-live.jpg).

### Limits

This is a temporary classroom deployment, not a public service: no authentication, TLS ingress, replicated database or automated backups. The PVC protects data across a Pod restart, not deliberate volume deletion. Ingress Nginx matches the class exercise but is retired and is not a production recommendation. Images need rescanning over time. The demo records the running lab; an always-on AWS endpoint is not promised after cleanup.

## Course and submission

Requirements come from the instructor's [devops-heros repository](https://github.com/Nency-Ravaliya/devops-heros) and its linked official homework document. Personal notes are reference material, not extra assignment titles.

The [Section A homework form](https://forms.gle/ydjAJcwxjpjBXgxB8) asks for individual assignment README links. The separate [capstone form](https://forms.gle/XWAP1vAumDJgAPM1A) asks for the repository link and requires the official SST email. Its confirmed deadline is **16 October 2026, 11:59 PM IST**. Follow the instructor's [submission guide](https://github.com/Nency-Ravaliya/devsecops-python/blob/main/SUBMISSION.md) and [rubric](https://github.com/Nency-Ravaliya/devsecops-python/blob/main/GRADING.md), not the mistaken date in that file. No form has been submitted from this work. Earlier homework resources were cleaned up; the capstone lifecycle records are linked in its evidence index.
