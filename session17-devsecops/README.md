# Session 17 — DevSecOps

Archit Kulkarni | 24BCS10194 | Section A

The [Flask API](app.py) has a home page, `/health`, greeting and numeric-addition endpoints. [Tests](tests/) cover normal requests, invalid input and missing routes. The [Dockerfile](Dockerfile), [deployment](kubernetes/deployment.yaml) and [security configuration](security/) are included beside the application.

## Pipeline and gates

The [workflow](../.github/workflows/devsecops.yml) follows:

```text
pytest -> Bandit -> pip-audit -> Gitleaks
             -> Docker build -> Trivy -> GHCR push
             -> real Kubernetes rollout -> HTTP smoke test
```

Every gate must pass before publication/deployment. Trivy exits nonzero for HIGH or CRITICAL vulnerabilities; there is no CVE ignore list. The image runs as UID 10001, and the Deployment adds probes, resource limits and restricted container settings.

The [successful run](https://github.com/archit0k/Devops-HW/actions/runs/37655885319) passed eight tests, SAST, dependency audit, full-history secret scan, image scan, registry publication and actual deployment to a disposable kind cluster. The `/health` request returned the name and roll number. The cluster was deleted after verification.

![Completed DevSecOps pipeline](evidence/pipeline.jpg)

Run the local commands from `session17-devsecops/`. The Kubernetes commands require a running lab cluster and the tested image tag.

```bash
pip install -r requirements-dev.txt
pytest -v
bandit -r app.py -c security/bandit.yaml -ll
pip-audit -r requirements.txt
docker build -t homework-api:local .
kubectl apply -f kubernetes/deployment.yaml
kubectl set image deployment/homework-api app=<the-tested-image-tag>
kubectl rollout status deployment/homework-api
```

The workflow replaces the manifest's `homework-api:ci` image with the exact tested commit-SHA tag. Publishing uses GitHub's short-lived workflow token; the deployment target is the runner's disposable Kind cluster.

[Security notes](security/README.md) explain what each scanner covers and the narrowly documented historical teaching-value fingerprints in `.gitleaksignore`. Flask's development server is sufficient for this classroom API, not a production serving recommendation.
