# StudySlot recording guide

Archit Kulkarni, 24BCS10194, Section A

This is the recording checklist, not another assignment. Read [speaking-script.md](speaking-script.md) alongside it. The instructor asks for slides first, followed by code, a push-triggered pipeline, Terraform/AWS, Argo CD, Kubernetes, Prometheus and Grafana. Allow about 10–13 minutes of finished video. This timing is a suggestion, not an instructor limit. Record the real actions and shorten waiting periods honestly.

Recording is paused as of 17 October (IST). The local demo is stopped with its database and SQL backup preserved, and the temporary AWS lab has been removed. The [rehearsal status](../project/evidence/rehearsal-20261016/README.md) links the verification records. Keep both environments off until the next recording window.

After setup is resumed, if this laptop's prepared session is already running and the preflight passes, start at **Scene 1**. Sections 2–3 explain a cold start and must not be repeated blindly. In particular, do not run another Terraform apply or a second forwarding process during an already prepared recording.

## 1. Before recording

1. Plug the laptop in. Close unrelated tabs and applications. Silence notifications and hide personal messages.
2. Use a screen recorder you already trust. Choose the entire screen if you will switch between slides, a terminal and the browser. Record a ten-second microphone sample and play it back. No webcam requirement appears in the supplied instructions.
3. Use 1920 × 1080 if available, readable browser zoom and a terminal font around 20–24 px. Do not record passwords, AWS sign-in, environment files, Secrets, Terraform state or private evidence.
4. Open this guide and the speaking script on a second device or outside the captured area.
5. Open `demo/presentation.pptx` in PowerPoint. Alternatively open `demo/slides.html` locally in a browser. Start the slideshow at slide 1. Do not screen-record PowerPoint's editing ribbon for the slide segment.
6. Open the repository in your code editor. Keep the Explorer visible, but collapse unrelated assignment folders. Expand `project/` and `.github/workflows/`.
7. Open two PowerShell tabs and two Ubuntu shells as described below. Sign in to AWS and GitHub before recording.

### Recording on Windows 11 without another install

1. Open **Snipping Tool** from Start. Choose **Record**, then **New**, or press **Windows + Shift + R**.
2. Drag a rectangle covering the screen area you will use for slides, browser and terminal. Keep every scene inside it.
3. Turn on the microphone icon, choose the correct microphone and enable computer audio if needed. Complete any permission prompt yourself.
4. Record ten seconds of speech, stop and play it back. Check that text is readable and your voice is audible.
5. Return to slide 1, start a new recording and click **Start**. Switch apps inside the same captured region.
6. At the end click **Stop**, save the MP4 and play it back. Keep the raw file outside Git until its size and contents are checked. Snipping Tool also offers **Edit in Clipchamp** if you need to trim long waits.

If your installed Snipping Tool lacks video or microphone controls, use a screen recorder already installed and test its whole-screen capture. Do not spend the deadline window installing or learning an unfamiliar editor. [Microsoft's recording instructions](https://support.microsoft.com/en-gb/windows/apps/use-snipping-tool-to-capture-screenshots) and [microphone guidance](https://www.microsoft.com/en-us/windows/learning-center/how-to-use-snipping-tool-on-windows-screenshots-shortcuts-and-screen-recordings/) describe the current Windows tool.

Do not begin a fresh EKS creation just for rehearsal. The cloud lab is temporary, costs money while present and must be removed after its recording segment. The complete AWS setup sequence is below for an approved recording window.

## 2. Terminal setup

### PowerShell A: repository and GitHub

Run these in Windows PowerShell, not Ubuntu:

```powershell
Set-Location 'C:\Users\archi\Github Projects\Devops-HW'
$ghExe = 'C:\Users\archi\AppData\Local\DevOpsHomeworkTools\gh-2.102.0\bin\gh.exe'
git status --short
git branch --show-current
& $ghExe auth status
```

The branch should be `main`. Review every modified file before committing. Do not blindly stage the whole repo or overwrite uncommitted work. If setup is already complete, verify it instead of repeating it.

### Ubuntu A: live commands

Open a second terminal and enter:

```powershell
wsl -d Ubuntu -u root
```

The prompt is now Bash. Run:

```bash
cd "/mnt/c/Users/archi/Github Projects/Devops-HW"
export PATH="/root/.local/bin:/root/.minikube/cache/linux/amd64/v1.37.0:$PATH"
export AWS_PROFILE=devops-homework AWS_REGION=us-east-1 AWS_DEFAULT_REGION=us-east-1 AWS_PAGER=''
bash project/scripts/resume-local.sh
```

This resumes the existing Minikube container and preserves its database. It does not create AWS infrastructure. A fresh machine would instead need the full setup in [project/README.md](../project/README.md). Do not delete the cluster or its volumes to fix a startup problem.

### Ubuntu B: keep the demo URLs available

Open another Ubuntu root shell, set the same working directory and PATH, then run:

```bash
bash project/scripts/forward-local.sh
```

Leave this terminal running, minimized. Its forwarding messages are normal. If it is already running, do not launch a duplicate. These forwards keep WSL active during recording. Do not close them between scenes.

### Browser tabs, in recording order

| Tab | Address / page | What must be visible |
| --- | --- | --- |
| Repository | https://github.com/archit0k/Devops-HW | Public source and README |
| Actions | https://github.com/archit0k/Devops-HW/actions/workflows/studyslot.yml | The new push run |
| AWS VPC | https://us-east-1.console.aws.amazon.com/vpcconsole/home?region=us-east-1#vpcs: | `studyslot-vpc`, two subnets / resource map |
| AWS EKS | https://us-east-1.console.aws.amazon.com/eks/home?region=us-east-1#/clusters | `archit-studyslot`, Active, node group |
| Argo CD | http://localhost:8081 | StudySlot Synced / Healthy |
| Application | http://localhost:3000 | Booking form and existing bookings |
| Swagger | http://localhost:8000/docs | Booking API routes |
| Prometheus | http://localhost:9090/targets | StudySlot targets UP |
| Grafana | http://localhost:3001/d/archit-studyslot | Populated StudySlot dashboard |

Log into Argo CD and Grafana privately before recording. Argo CD uses `admin`; Grafana uses `archit`. Existing local passwords come from runtime Kubernetes Secrets. Do not paste them into this guide, Git, the recording or chat. The ignored `private-evidence/demo-logins.json` is local convenience data, not a submission artifact.

### Preflight, off camera

In Ubuntu A:

```bash
kubectl --context minikube -n studyslot get pods
kubectl --context minikube -n argocd get application studyslot
bash project/scripts/verify-local.sh
```

Do not record until the app Pods are Ready, Argo is Synced/Healthy, the CRUD check passes and Prometheus reports UP. A successful startup command alone is not enough.

For dashboard data, run in a spare Ubuntu shell:

```bash
python3 project/scripts/demo-traffic.py --seconds 180
```

This sends a small GET-only sample and exits by itself. It does not create bookings. Let Prometheus collect several samples. In Grafana choose Last 15 minutes and Refresh 10 seconds. New rate/latency panels need more than one scrape.

## 3. Fresh AWS setup, before the main recording

Only do this during the agreed short recording window. Keep the current $30 total cap, including earlier labs. Never show AWS login or keys on camera. A Terraform plan is read-only, but applying it starts billable infrastructure.

In Ubuntu A:

```bash
aws sts get-caller-identity --profile devops-homework --region us-east-1
aws iam list-open-id-connect-providers --region us-east-1
terraform -chdir=project/terraform init
terraform -chdir=project/terraform validate
bash project/scripts/terraform-lab.sh plan
bash project/scripts/terraform-lab.sh apply
```

The current ignored `project/terraform/terraform.tfvars` reuses the account's pre-existing GitHub OIDC provider. It must not be imported into this lab's state or deleted with this lab. On another machine, set `existing_github_oidc_arn` in an ignored tfvars file if that provider already exists. Keep the resource ownership separate.

Record the fresh plan summary and apply completion as a short separate clip if the full wait is long. Keep the real output. Do not replay an old log and describe it as a newly executed command.

The EKS setup uses the temporary GitHub OIDC role because this account's root session cannot directly use Kubernetes access. In PowerShell A:

```powershell
$deployRole = (wsl -d Ubuntu -u root --exec terraform -chdir=project/terraform output -raw github_deploy_role_arn).Trim()
& $ghExe variable set AWS_DEPLOY_ROLE_ARN --repo archit0k/Devops-HW --body $deployRole
& $ghExe workflow run studyslot-aws-lab.yml --repo archit0k/Devops-HW --ref main -f action=bootstrap -f image_sha=ea51f5a57bcb2fd435a33cc64a91730c17b824f3
& $ghExe run list --repo archit0k/Devops-HW --workflow studyslot-aws-lab.yml --limit 3
```

Open the new bootstrap run and wait for its checks to pass. The image SHA above is the already tested, pinned local release, not a placeholder. Then restrict temporary setup access in Ubuntu A:

```bash
bash project/scripts/terraform-lab.sh restrict
```

In PowerShell A, enable cloud CD only while the cluster is present:

```powershell
& $ghExe variable set ENABLE_EKS_CD --repo archit0k/Devops-HW --body true
```

AWS creation can take substantial time. Never fabricate an Active cluster or passing deployment to meet a recording schedule. If setup fails, retain the failure, clean up and use the genuine earlier AWS footage with an explicit date/description instead of calling it a live deployment.

## 4. Recording sequence

### Scene 1: presentation, about 2–3 minutes

Start recording with the slideshow full screen. Present the twelve slides in order using the matching lines in [speaking-script.md](speaking-script.md). Explain the application and architecture rather than reading every label. Screenshots are supporting evidence; the live walkthrough follows.

### Scene 2: codebase, about 1 minute

Switch to the editor. Show these files briefly, in this order:

1. `project/backend/app/main.py`: FastAPI routes, validation, health and metrics.
2. `project/backend/app/models.py`: `UniqueConstraint("room", "booking_date", "start_hour")`.
3. `project/backend/alembic/versions/001_bookings.py`: database migration.
4. `project/frontend/`: React UI and API calls.
5. `project/backend/tests/test_bookings.py`: isolated tests and representative cases.
6. `project/backend/Dockerfile`, `project/frontend/Dockerfile`, `project/docker-compose.yml`: non-root users, multi-stage frontend, internal PostgreSQL.
7. `.github/workflows/studyslot.yml`: jobs and HIGH/CRITICAL security gate.

Point to the code you are explaining. Do not scroll through hundreds of lines. Optional live test command, in Ubuntu A, if the existing test environment is available:

```bash
(cd project/backend && /tmp/studyslot-tests/bin/pytest -v)
```

If that temporary environment is absent, prepare it off camera with `bash project/scripts/run-tests.sh`. Do not spend recording time installing packages.

### Scene 3: real Git change and CI/CD, about 1–2 minutes plus the wait

In the editor open `project/gitops/values-local.yaml`. Change only:

```yaml
demoRevision: recording-20261016
```

Use a new value if that exact value is already present. Keep the tested `imageTag` unchanged. This is a real configuration change: the chart uses it in the backend Pod annotation and ConfigMap, causing a rollout.

In PowerShell A:

```powershell
git diff -- project/gitops/values-local.yaml
git add project/gitops/values-local.yaml
git commit -m "Update recording revision"
git push origin main
& $ghExe run list --repo archit0k/Devops-HW --workflow studyslot.yml --limit 3
```

Open the run for that commit in Actions. Show it running, then its completed jobs. Open the test results, image scan and SHA-tagged package steps briefly. If AWS CD is enabled and the lab exists, show `deploy_aws` passing too. If it is disabled, say so; a skipped job is not a passed AWS deployment.

You may remove dead waiting time with a clear cut such as “after the pipeline finishes.” Show the same run and commit before/after the cut. Do not substitute another run without explaining it.

### Scene 4: Terraform and AWS, about 1 minute

Show the fresh plan/apply clip or execute a fresh plan while recording. After access restriction, this command should describe the current infrastructure without intentionally restoring cluster-admin access:

```bash
terraform -chdir=project/terraform plan -input=false -no-color -var=bootstrap_cluster=false
```

A no-change plan now is expected. The earlier completed lab managed 26 resources. The new lab reuses a pre-existing OIDC provider and therefore manages 25, with the initial provider-conflict attempt and its four-resource repair plan retained in the rehearsal evidence. Explain the resource ownership instead of calling a partial attempt a successful full apply. Switch to AWS Console, select `us-east-1` and show:

1. VPC `studyslot-vpc`, CIDR `10.42.0.0/16`, resource map and the two public subnets in separate zones.
2. EKS `archit-studyslot` with status Active.
3. Compute / managed node group `classroom`, with its two workers.

Do not claim localhost is the public AWS endpoint. The browser demo and Argo CD run on local Minikube. The separate Actions job deploys and verifies the app on EKS. The cloud Ingress controller uses ClusterIP, so no public application LoadBalancer is promised.

### Scene 5: Argo CD, about 45 seconds

Open http://localhost:8081 and select StudySlot. Click Refresh if it has not detected the commit yet. Show the Git revision, Synced and Healthy status, then the backend Deployment/Pods in the resource tree.

In Ubuntu A:

```bash
kubectl --context minikube -n argocd get application studyslot
kubectl --context minikube -n studyslot rollout status deployment/backend --timeout=180s
kubectl --context minikube -n studyslot get configmap studyslot-config -o yaml
```

The final ConfigMap command is optional; verify its actual name with `kubectl --context minikube -n studyslot get configmaps` first. Never show a Secret. Explain that Argo follows `main`, while the local application image remains pinned to an already tested SHA.

### Scene 6: Kubernetes and the application, about 1–2 minutes

In Ubuntu A run, leaving each result readable:

```bash
kubectl --context minikube -n studyslot get pods -o wide
kubectl --context minikube -n studyslot get svc
kubectl --context minikube -n studyslot get ingress
kubectl --context minikube -n studyslot get pvc,hpa
helm list -n studyslot
curl -fsS http://localhost:8000/health
curl -fsS http://localhost:8000/ready
```

Show two Ready frontend replicas, at least two Ready backend replicas and PostgreSQL. Point out the internal Services, Ingress routing and Bound PVC.

Open http://localhost:3000. Use only your own synthetic demo details:

1. Name `Archit Kulkarni`, roll `24BCS10194`.
2. Choose Library B, a date with no existing booking and an available hour, with 2 people.
3. Click Book this slot. Show the new booking.
4. Try the exact room/date/hour again. Show the conflict message.
5. Edit the booking to a different available hour and save.
6. Refresh to show the change remains, then cancel only the booking you just created.
7. Briefly open Swagger and show GET, POST, PUT and DELETE routes.

For the concurrent PostgreSQL check, run:

```bash
python3 project/scripts/check-api.py
```

Point to the concurrent 201/409 result. That helper removes its own test records. Never delete existing bookings just to make the screen cleaner.

### Scene 7: Prometheus, about 30 seconds

In Ubuntu A:

```bash
curl -fsS http://localhost:8000/metrics
```

Show `studyslot_http_requests_total` and the request-duration histogram. Open http://localhost:9090/targets, filter for `studyslot` and show every backend target UP. The HPA allows two to four replicas, so the target count can change. If the newer Prometheus UI groups targets, expand the StudySlot ServiceMonitor row.

### Scene 8: Grafana, about 45 seconds

Open http://localhost:3001/d/archit-studyslot. Set Last 15 minutes, Refresh 10 seconds. Show target count, request count/rate and a populated latency panel. Generate a few requests by refreshing the application, then return to Grafana and refresh. Do not describe an empty panel as populated. A zero error rate is a valid result, not a broken graph.

### Scene 9: cleanup and conclusion, about 30 seconds of finished footage

Say that the lab is temporary and record the real teardown completion. The cleanup wait can be cut. Perform the steps below before leaving the laptop. End with the limitations and one concrete thing learned.

## 5. AWS cleanup, immediately after its recording

Before removing the application, in Ubuntu A capture this lab's exact IDs:

```bash
python3 project/scripts/check-recording-cleanup.py capture
```

In PowerShell A:

```powershell
& $ghExe variable set ENABLE_EKS_CD --repo archit0k/Devops-HW --body false
& $ghExe workflow run studyslot-aws-lab.yml --repo archit0k/Devops-HW --ref main -f action=cleanup -f image_sha=ea51f5a57bcb2fd435a33cc64a91730c17b824f3
& $ghExe run list --repo archit0k/Devops-HW --workflow studyslot-aws-lab.yml --limit 3
```

Wait for the cleanup run to finish. It removes the app and database PVC while the CSI driver still exists. It intentionally discards the temporary AWS demo database, not the preserved local database. If bootstrap never installed the app, inspect the actual cluster state before attempting its cleanup action.

In Ubuntu A:

```bash
bash project/scripts/terraform-lab.sh destroy
terraform -chdir=project/terraform state list
aws eks list-clusters --region us-east-1
aws ec2 describe-vpcs --region us-east-1 --filters Name=tag:Project,Values=studyslot-homework
aws ec2 describe-volumes --region us-east-1
python3 project/scripts/check-recording-cleanup.py check
```

Save the destroy output and verify the exact resources from this recording are gone. Do not reuse a leftover checker containing the previous VPC/volume IDs and assume it proves this new lab was removed. Keep ignored Terraform state until teardown succeeds. Do not delete unrelated account resources.

To stop the local demo after the entire recording:

```bash
bash project/scripts/stop-local.sh
```

It saves an ignored SQL backup, stops Minikube and restores its smaller stopped-container limits. It stops Docker only if no other containers are running. Do not use `minikube delete`, `docker system prune` or `docker compose down -v` as recording cleanup.

## 6. Final video and submission checks

1. Play the exported MP4 from beginning to end. Check voice, readable text, slide order and every live section. Keep genuine failures if discussed, or re-record the corrected step honestly.
2. Put the final MP4 under `demo/`, with the current deck. Update the demo README if you replace the earlier 7:39 captioned recording. Do not claim the old MP4 contains the new deck or your new narration.
3. Check file size before pushing. GitHub rejects ordinary Git files over 100 MiB. Prefer an MP4 small enough for normal Git, or attach a larger video as a GitHub release asset and link it from `demo/README.md`, as permitted by the rubric. Do not commit a huge raw recording by mistake.
4. Stage only the intended deliverables. Use a specific commit message, push and open the public repo links to verify access.
5. Confirm AWS teardown and that `ENABLE_EKS_CD` is false.
6. Submit the repository link once using the official SST email. The user, not this runbook, controls submission. No form is submitted automatically.

## If something goes wrong

| Symptom | First check | Safe next step |
| --- | --- | --- |
| localhost refuses connection | Forwarding terminal and `kubectl --context minikube get nodes` | Resume the preserved lab, then restart the forwards; do not create a second cluster |
| Kubernetes API connection refused after WSL restart | `docker ps -a`, `minikube status` | Resume the existing profile and keep the forwarding terminal alive |
| Argo Synced but Degraded | `kubectl --context minikube -n studyslot get pods,ingress` and Argo health message | Wait for the affected resource or diagnose its events; do not call it Healthy prematurely |
| ImagePullBackOff | Pod events and already cached SHA images | Restore the tested cached image or registry access, not an arbitrary `latest` image |
| Grafana has no recent data | Prometheus targets and time range | Send bounded demo traffic and wait for several scrapes |
| AWS session expired | `aws sts get-caller-identity` | Sign in privately using the existing temporary profile; never paste keys into Git/chat |
| Pipeline fails a scan | Failed job's actual output | Fix and rerun honestly; never disable the required security gate |

## Official requirements

- [Submission instructions](https://github.com/Nency-Ravaliya/devsecops-python/blob/main/SUBMISSION.md)
- [Grading rubric](https://github.com/Nency-Ravaliya/devsecops-python/blob/main/GRADING.md)

The instructor's message confirms 16 October 2026, 11:59 PM IST. The different date inside SUBMISSION.md is not the confirmed deadline.
