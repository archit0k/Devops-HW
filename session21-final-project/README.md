# Session 21 - TaskBoard walkthrough and troubleshooting

Archit Kulkarni | 24BCS10194 | Section A

This assignment executes the instructor's [Session 21 TaskBoard README](https://github.com/Nency-Ravaliya/devops-heros/blob/main/session21-python/README.md). The separate student project is [StudySlot](../project/README.md), not this exercise.

## What I ran

The instructor's TaskBoard source is in [taskboard](taskboard/). This is the supplied React + FastAPI + PostgreSQL lab, not my original project. The old folder name is kept so the submitted README link does not change.

Checked on 8 October 2026. The [latest GitHub Actions run](https://github.com/archit0k/Devops-HW/actions/runs/37748387679) passed all three stages: test, images and deploy. It ran the direct backend check, three Pytest tests, frontend build, Compose CRUD checks, both image scans, GHCR publishing and a Helm deployment on a disposable Kubernetes cluster. Local Compose builds hit a DNS error; the successful application execution below is on the GitHub-hosted Ubuntu runner.

![TaskBoard test, images and deployment jobs passed](evidence/ci-deploy-passed.jpg)

| Walkthrough | Commands/checks | Result and record |
| --- | --- | --- |
| Docker Compose | `docker compose up --build -d`, `ps`, health/ready/docs/metrics requests, frontend and CRUD, `docker compose down` | Passed. Three services ran; backend ran as UID 10001. [Full output](evidence/complete-run/compose.txt) |
| Direct backend | `python -m venv .venv`, install requirements, `alembic upgrade head`, `alembic current`, `uvicorn app.main:app` | Passed with a separate PostgreSQL container. Health, tasks and Swagger returned HTTP 200; creating a task returned 201. [Full output](evidence/complete-direct/direct-backend.txt) |
| Database | `psql ... SELECT id,title,status,assignee FROM tasks;` | The inserted row belonged to Archit Kulkarni. Compose also verified an update to DONE and deletion. Both records above contain the actual SQL output. |
| Pytest and frontend | `pytest -q`, `npm ci`, `npm run build` | Three tests passed; frontend production build passed. [Test job](https://github.com/archit0k/Devops-HW/actions/runs/37748387679/job/113215301416) |
| Git/GitHub | Existing repository, `git add`, `git commit`, `git push origin main` | Changes are on `main`. I kept the existing history and remote rather than reinitialising the repository or adding a second origin. |
| Docker images | Compose built both Dockerfiles; images tagged with the tested commit SHA | Backend and frontend images built successfully. [Image job](https://github.com/archit0k/Devops-HW/actions/runs/37748387679/job/113215614789) |
| Trivy gate | `trivy image --scanners vuln --severity HIGH,CRITICAL --exit-code 1` on both images | Both passed with zero HIGH/CRITICAL findings at scan time. [Backend](evidence/complete-run/backend-scan.txt), [frontend](evidence/complete-run/frontend-scan.txt) |
| Registry | `docker push ghcr.io/archit0k/taskboard-{backend,frontend}:<tested-sha>` | Both tested SHA tags were pushed by CI. No AWS credentials were given to GitHub Actions. |
| Terraform | `init`, `fmt`, `validate`, `plan` | Init and validation passed; the new plan proposed 66 additions including Metrics Server. [Init](evidence/terraform-init.txt), [latest validation](evidence/terraform-validate-complete.txt), [successful plan](evidence/terraform-plan-complete.txt) |
| AWS apply | `terraform apply lab.tfplan` | Passed: 66 resources added, including EKS 1.35, two managed worker nodes, EBS CSI and Metrics Server. [Apply output](evidence/terraform-apply-complete.txt), [console screenshot](evidence/eks-active.jpg) |
| CI Kubernetes deployment | Namespace, Secret, `helm upgrade --install`, Deployments, Services, PostgreSQL PVC and API checks | Passed on the runner's Kubernetes 1.35 cluster. All three app Pods became Ready; PVC was Bound; a task was created, read and deleted through the actual API. Helm release and namespace were removed. [Output](evidence/ci-deployment/kubernetes.txt), [deploy job](https://github.com/archit0k/Devops-HW/actions/runs/37748387679/job/113216123248) |
| AWS Kubernetes access | Configure kubeconfig, then check nodes | Blocked: AWS rejected root assuming the lab role. No successful AWS application deployment is claimed. [Actual failure](evidence/eks-deployment.txt) |
| AWS cleanup | `terraform destroy -auto-approve` | Passed: 66 resources destroyed, exit code 0. [Latest cleanup](evidence/terraform-destroy-access-pause.txt). The earlier partial run's [49-resource cleanup](evidence/terraform-destroy.txt) is preserved separately. |
| Access preflight | `terraform plan` without a non-root principal | Expected rejection, exit code 1: the new guard prevents another root-only access setup from provisioning. This check was plan-only; it created nothing. [Guard output](evidence/root-access-guard.txt) |
| Ingress and live demo | Apply dev values, route frontend and `/api`, open app and Swagger | Still pending. CI port-forward checks are not proof of Ingress routing or live browser screenshots. |
| HPA / monitoring | TaskBoard HPA, ServiceMonitor, Prometheus and Grafana | TaskBoard execution and screenshots still pending. |
| Troubleshooting | Supplied broken-image and broken-Service manifests; diagnose, fix and verify | TaskBoard execution still pending. |

## Re-running the completed checks

From the repository root on Linux/WSL:

```bash
bash session21-final-project/run-compose.sh
bash session21-final-project/run-backend.sh
```

[Compose helper](run-compose.sh) creates a temporary password without printing it, waits for readiness, checks the real API and database, and stops the services on exit. [Direct-backend helper](run-backend.sh) uses a fresh virtual environment, PostgreSQL on loopback port 15433 and Uvicorn on port 8000, then removes its test-only PostgreSQL container. Run them one at a time because both use port 8000. Removing a Compose volume with `docker compose down -v` also removes its test database; it is not needed just to stop the services.

The tested image tag is `25ef8e537db59c165ce4e9fe8f6d4c2e1d4e787f`:

```text
ghcr.io/archit0k/taskboard-backend:25ef8e537db59c165ce4e9fe8f6d4c2e1d4e787f
ghcr.io/archit0k/taskboard-frontend:25ef8e537db59c165ce4e9fe8f6d4c2e1d4e787f
```

## Fixes needed for the walkthrough

- The supplied backend tests needed the `TestClient` startup context so the test table was created. The application is still the instructor's TaskBoard.
- The first security gate failed on vulnerable Python dependencies. I updated the affected dependencies and removed build-only pip tooling from the runtime image. The gate stayed enabled; no vulnerability was suppressed. [First backend scan](evidence/first-run/backend-scan.txt), [failed run](https://github.com/archit0k/Devops-HW/actions/runs/37668813204).
- Compose's PostgreSQL host port is 15432 to avoid an existing port 5432 service. Container-to-container connections still use 5432.
- The frontend proxy expects `backend:8000`. The Helm chart now provides that Service alias; the Ingress references the chart's actual backend Service name and port, 8000.
- Database credentials come from an existing Kubernetes Secret, not a committed password. Both application Deployments accept image-pull secrets if needed.
- PostgreSQL uses `PGDATA` below the mounted volume directory, so EBS's `lost+found` does not break database initialization. `Recreate` avoids two PostgreSQL Pods trying to write to the same single-writer PVC during an update.
- The Terraform HCL was formatted into valid module blocks. EKS uses a supported Kubernetes version, AL2023 nodes, EBS CSI and Metrics Server. The attempted access role did not work with AWS root: root cannot assume roles. Non-root lab access needs approval before another cloud deployment attempt. No AWS credentials were stored in GitHub Actions.
- CI deploys the exact scanned SHA images on an isolated Kind cluster. This tests the deploy stage without leaving a cloud cluster running or giving the runner AWS account access. EKS application verification remains separate.

## Remaining work

The assignment is not fully verified yet. Terraform and the three-stage pipeline are complete. Next: obtain non-root AWS lab access or finish the classroom checks locally, mirror/load the tested images, run Ingress with the app and Swagger open, replace the PostgreSQL Pod and verify its data survives, exercise HPA and monitoring, and run both troubleshooting cases with before/after output and screenshots. The local restart reached a running cluster but its command checks selected the AWS credential context; [that unsuccessful attempt](evidence/local-cluster-ready.txt) is preserved, and the helper now explicitly selects Minikube. StudySlot remains paused in [project](../project/README.md).

Nothing has been submitted by this repository workflow.

The latest cloud lab was destroyed, and [the new read-only check](evidence/access-pause-check.txt) found no EKS clusters, non-terminated EC2 instances, EBS volumes, active NAT gateways, Elastic IP allocations, TaskBoard VPC/ECR repositories or S3 buckets in the lab regions. The new KMS key is in `PendingDeletion`. The [earlier pause check](evidence/pause-check.txt) belongs to the previous run. Local Minikube, [Docker/containerd](evidence/local-services-stopped.txt) and the temporary AWS proxy are stopped. Windows DNS was not changed; Ubuntu is using its original WSL resolver. Source and test results are preserved. No new IAM user or access key has been created while the permission decision is pending.

[Local README link check](evidence/readme-link-check.txt): all 117 local links passed.
