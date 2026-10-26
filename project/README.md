# StudySlot — Study-room booking

Archit Kulkarni | 24BCS10194 | Section A

StudySlot lets a student reserve, change or cancel a one-hour study-room booking. Library A and B hold four people each; the group room holds six. PostgreSQL prevents duplicate bookings for the same room, date and hour, even when two requests arrive together.

This is separate from the instructor's [TaskBoard walkthrough](../session21-final-project/README.md). It is a classroom application with synthetic bookings, not an official campus service.

![StudySlot booking page](screenshots/application.jpg)

## Work completed

| Area | Implementation and result | Review |
| --- | --- | --- |
| Application | React frontend, FastAPI CRUD, PostgreSQL and Alembic migration | [Backend](backend/app/), [frontend](frontend/), [migration](backend/alembic/versions/001_bookings.py), [mobile view](screenshots/mobile.jpg) |
| Tests | 16 API tests; separate HTTP checks cover PostgreSQL CRUD and simultaneous 201/409 responses | [Tests](backend/tests/), [integration check](scripts/check-api.py), [test output](screenshots/tests.jpg) |
| Git | Source, manifests and changes tracked in this repository | [History](https://github.com/archit0k/Devops-HW/commits/main/), [recorded history](screenshots/commits.jpg) |
| Docker | Non-root backend, multi-stage frontend, Compose stack and migration service | [Compose](docker-compose.yml), [backend Dockerfile](backend/Dockerfile), [frontend Dockerfile](frontend/Dockerfile), [results](screenshots/compose.jpg) |
| CI/CD | Tests and security gates → SHA-tagged GHCR images → Kind verification → optional EKS deployment | [Workflow](../.github/workflows/studyslot.yml), [six-job passing run](https://github.com/archit0k/Devops-HW/actions/runs/38943691357), [pipeline screenshot](screenshots/pipeline.jpg) |
| Security | Ruff, Bandit, dependency audits, Gitleaks and both Trivy image scans | [Security notes](security/README.md), [backend scan](screenshots/security-backend.jpg), [frontend scan](screenshots/security-frontend.jpg) |
| Terraform/AWS | Two-zone VPC, EKS and two managed workers; infrastructure removed after checks | [Terraform](terraform/README.md), [VPC](screenshots/aws-vpc.jpg), [EKS](screenshots/aws-eks.jpg), [earlier destroy result](screenshots/terraform-destroy.jpg) |
| Kubernetes/Helm | Deployments, Services, Ingress, probes, HPA and PostgreSQL PVC; data survived a Pod replacement | [Chart](helm/studyslot/), [resources](screenshots/kubernetes.jpg), [persistence](screenshots/storage.jpg) |
| GitOps/monitoring | Argo CD Synced/Healthy, Prometheus targets UP and populated Grafana metrics | [GitOps](gitops/), [monitoring](monitoring/), screenshots below |
| Presentation | Technical documentation and the final slide deck are included | [Deck and video location](../demo/README.md); recording will be added later |

Screenshots are from completed checks on 16 October 2026. Images of command output show saved execution records; browser images show the application or console. The AWS lab and local demo are stopped.

## Architecture and files

```text
Browser → Ingress ┬→ /     → React/Nginx
                  └→ /api  → FastAPI → PostgreSQL/PVC
                              └→ /metrics → Prometheus → Grafana
GitHub → tests/audits → Docker/Trivy → GHCR SHA images → Helm/Kind → EKS
Git chart + pinned values → Argo CD → local Kubernetes
Terraform → VPC + two public subnets + EKS + two workers
```

| Folder | Contents |
| --- | --- |
| `backend/` | API, schemas, models, migration and tests |
| `frontend/` | React booking interface and Nginx proxy |
| `helm/studyslot/` | Application chart and runtime configuration |
| `k8s/` | Namespace, storage and namespace-scoped CI permissions |
| `terraform/` | AWS infrastructure and dependency lock file |
| `monitoring/` | Prometheus values and provisioned Grafana dashboard |
| `gitops/` | Argo CD Application and tested image values |
| `scripts/` | Build, deployment and verification helpers |
| `screenshots/` | Selected application, pipeline and infrastructure results |

## Application and API

Python 3.14, FastAPI, SQLAlchemy, Alembic, PostgreSQL 17, React/Vite, Nginx, Docker, GitHub Actions, Trivy, Terraform, Kubernetes, Helm, Argo CD, Prometheus and Grafana.

| Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/health` | Process health |
| GET | `/ready` | Database readiness; 503 if unavailable |
| GET | `/api/rooms` | Rooms and capacities |
| GET / POST | `/api/bookings` | List or create bookings |
| GET / PUT / DELETE | `/api/bookings/{id}` | Read, edit or cancel a booking |
| GET | `/metrics` | Prometheus metrics |

Create returns 201, duplicate slots return 409, invalid input returns 422, missing IDs return 404 and deletion returns 204. Names and roll numbers are trimmed, extra fields are rejected, and room capacity is validated. The unique database constraint also protects concurrent requests. Request logs contain IDs, routes, status and duration rather than submitted student details.

## Run with Docker Compose

Requirements: Docker Engine/Desktop with Compose and free local ports 3000 and 8000. From the repository root:

```bash
cd project
cp .env.example .env
# Set POSTGRES_PASSWORD in the ignored .env file before starting.
docker compose up --build -d
docker compose ps -a
curl http://localhost:8000/health
curl http://localhost:8000/ready
```

Open [the application](http://localhost:3000) and [Swagger](http://localhost:8000/docs). PostgreSQL becomes healthy before the migration service runs; the API starts after the migration completes. The database has no published host port. Both application images run as non-root users.

```bash
docker compose down
```

This preserves the named database volume. `down -v` deletes it. An existing volume keeps its original password, so changing `.env` alone does not change that password.

## Backend setup and tests

For a direct development run, use Python 3.14 and run from the repository root:

```bash
cd project/backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
alembic upgrade head
pytest -v
ruff check app tests alembic
bandit -r app -ll
pip-audit -r requirements.txt
uvicorn app.main:app --host 127.0.0.1 --port 8000
```

The direct-development default is SQLite; Compose and Kubernetes use PostgreSQL. Each unit test overrides the database with fresh in-memory SQLite, so tests do not delete application data. Cases cover CRUD, conflict handling, validation, metrics and database failure. [check-api.py](scripts/check-api.py) adds real HTTP and simultaneous-booking checks against the running stack.

## CI/CD and security

The [pipeline](../.github/workflows/studyslot.yml) has six jobs: tests, frontend checks, secret scanning, images, Kind deployment and optional AWS deployment. Python tests, Ruff/Bandit, Python/Node dependency audits and full-history Gitleaks run before image promotion. Both runtime images are scanned by Trivy; HIGH or CRITICAL findings stop publication.

Images are published to `ghcr.io/archit0k/studyslot-backend:<commit-sha>` and `ghcr.io/archit0k/studyslot-frontend:<commit-sha>`. The same scanned images are loaded into an isolated Kind cluster for Helm and HTTP checks. The optional EKS job runs afterward using short-lived GitHub OIDC credentials. [The recorded run](https://github.com/archit0k/Devops-HW/actions/runs/38943691357) passed all six jobs.

`ENABLE_EKS_CD` is disabled when the temporary cloud lab is absent. Scans describe the image and advisory database at scan time, not a permanent security guarantee. [Security notes](security/README.md) describe each gate and the narrowly scoped historical teaching-value exceptions.

## Terraform and AWS

The configuration provisions a `10.42.0.0/16` VPC in `us-east-1`, two public subnets in different zones, routing, EKS 1.35 and two `t3.medium` workers. EBS CSI/Pod Identity support persistent storage; Metrics Server supplies CPU data for HPA. There is no NAT gateway, RDS instance or public application LoadBalancer.

With a suitable AWS profile configured, from the repository root:

```bash
terraform -chdir=project/terraform init
terraform -chdir=project/terraform validate
bash project/scripts/terraform-lab.sh plan
bash project/scripts/terraform-lab.sh apply
# Bootstrap through studyslot-aws-lab.yml using an already scanned image SHA.
bash project/scripts/terraform-lab.sh restrict
```

The AWS role has `eks:DescribeCluster`; its regular Kubernetes access is limited to the `studyslot` namespace. Bootstrap administration is removed afterward. A namespace Role allows CI to manage ServiceMonitors. No IAM user or permanent deployment key is created. See [infrastructure notes](terraform/README.md) for OIDC setup and safe reuse of an existing provider.

The [AWS bootstrap](https://github.com/archit0k/Devops-HW/actions/runs/38942882934) passed Ingress CRUD, concurrent PostgreSQL requests, migration and non-root checks. Cleanup disabled cloud CD, [removed the app/PVC](https://github.com/archit0k/Devops-HW/actions/runs/38946391044), then destroyed Terraform resources. The final lab removed 25 managed resources and its recorded worker/database volumes; a pre-existing shared OIDC provider was left untouched.

## Kubernetes, Helm and GitOps

The chart creates two frontend replicas, backend HPA scaling from 2–4 replicas at 60% CPU, ClusterIP Services, `/` and `/api` Ingress routes, startup/readiness/liveness probes, migration init containers and PostgreSQL on a 2 GiB PVC. Migration init containers use a PostgreSQL advisory lock to avoid simultaneous schema changes.

For the local Minikube lab, Docker, Minikube, kubectl and Helm are required. Monitoring and Argo CD together need about 5 GiB RAM and six CPUs. From the repository root, with the tested images available:

```bash
bash project/scripts/prepare-local.sh ea51f5a57bcb2fd435a33cc64a91730c17b824f3
bash project/scripts/setup-gitops.sh
bash project/scripts/forward-local.sh
# In another shell:
bash project/scripts/verify-local.sh
```

Stop Compose before forwarding the same ports. Port 3000 forwards the Ingress controller; 8000 is the backend, 9090 Prometheus, 3001 Grafana and 8081 Argo CD. All bind to loopback. Runtime credentials stay in Kubernetes Secrets.

Argo CD watches the chart and [values-local.yaml](gitops/values-local.yaml), which pins the tested image SHA. The recorded `demoRevision` change updated a ConfigMap/Pod annotation and triggered a backend rollout. Auto-sync and self-healing are enabled; Argo ignores backend replica drift because the HPA owns that field.

![Argo CD synchronized and healthy](screenshots/argocd.jpg)

## Prometheus and Grafana

The [monitoring values](monitoring/values.yaml) install kube-prometheus-stack. A ServiceMonitor scrapes backend `/metrics`, and [dashboard.yaml](monitoring/dashboard.yaml) provisions target health, requests/rates, replicas, CPU, p95 latency and errors.

```promql
sum(up{namespace="studyslot"})
sum(studyslot_http_requests_total{namespace="studyslot"})
histogram_quantile(0.95, sum by (le) (rate(studyslot_http_request_duration_seconds_bucket{namespace="studyslot"}[5m])))
```

The recorded checks found healthy scrape targets and populated PromQL results. Metrics Server provides HPA CPU readings separately from Prometheus. Managed control-plane scrape jobs unavailable on EKS are disabled without disabling application scraping.

![Prometheus application targets UP](screenshots/prometheus.jpg)

![Grafana with application traffic and replica metrics](screenshots/grafana.jpg)

## Troubleshooting and lessons

| Issue | Cause and change | Verification |
| --- | --- | --- |
| Two students request one slot | Application-level checks alone can race; added database uniqueness and 409 handling | Concurrent requests return one 201 and one 409 |
| CI could not manage ServiceMonitor | EKS Edit access did not cover this custom resource | Added a namespace-only Role; AWS deployment job passed |
| Argo/Helm ownership conflict | Both tried to create the initial resources | Established Helm ownership first, then enabled Argo reconciliation |
| Existing Compose data rejected a new password | Changing environment variables did not change the stored database password | Preserved the original volume and used an isolated verification stack |

A passing test suite does not prove Service routing or database integration; HTTP checks cover those separately. A PVC survives Pod replacement, but deleting it is not a backup strategy. Kubernetes API permissions and AWS IAM permissions also need separate verification.

## Limits and presentation

This demo has no authentication, TLS ingress, replicated database or automated backup schedule. Use only disposable bookings. The classroom Ingress Nginx setup is retained for the exercise, not recommended for a new production deployment. Temporary cloud resources were removed after verification.

The [slide deck](../demo/presentation.pptx) is included. The [video folder](../demo/video/) is reserved for the recording and currently has no video. The instructor's [submission guide](https://github.com/Nency-Ravaliya/devsecops-python/blob/main/SUBMISSION.md) requires the MP4 as well, so the video deliverable remains outstanding.
