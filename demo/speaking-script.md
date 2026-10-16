# StudySlot speaking script

Use this as a prompt, not something to read word for word. Actions and exact commands are in [recording-guide.md](recording-guide.md). Say only what the screen actually demonstrates. The slide segment is about two to three minutes; the rest is the live demo.

## Slides

### 1. StudySlot

“Hi, I'm Archit Kulkarni, roll number 24BCS10194, Section A. This is StudySlot, a study-room booking app. I'll explain the setup briefly, then show the actual code, deployment and monitoring.”

### 2. The booking app

“A student can book a room for one hour, change the booking or cancel it. I used this domain instead of copying the TaskBoard example. Room capacity and duplicate-slot checks make it useful beyond a basic form.”

### 3. Architecture

“The browser reaches the React frontend through Ingress. API requests go to FastAPI, which stores bookings in PostgreSQL. Prometheus scrapes the backend, and Grafana displays those metrics. The database stays internal.”

### 4. Stack

“React and Vite handle the interface. FastAPI handles validation and the API, with SQLAlchemy and Alembic for the database. Docker packages the app. GitHub Actions checks it, and Helm, Terraform and Argo CD handle the deployment parts.”

### 5. Tests and conflicts

“There are sixteen API tests using an isolated test database. I also check real PostgreSQL over HTTP. For simultaneous requests for the same slot, one succeeds and the other returns 409 because the database enforces uniqueness.”

### 6. CI/CD

“A main-branch push runs tests, code checks and a secret scan. Both Docker images pass Trivy before publication. Images use the commit SHA as the tag, and the exact checked images go through a Kubernetes deployment test.”

### 7. AWS

“Terraform creates one VPC, two public subnets and an EKS cluster with two workers. GitHub uses temporary OIDC access. Setup access narrows to the application namespace afterward. I remove the lab when the demonstration is finished.”

### 8. Kubernetes

“The Helm chart defines frontend and backend replicas, internal Services and Ingress routes. PostgreSQL has a persistent volume. Readiness probes stop unready application Pods from receiving traffic.”

### 9. Argo CD

“Argo CD watches the chart and values in Git. A configuration change causes a real backend rollout. The local image stays pinned to a tested SHA, and the HPA manages backend scaling separately.”

### 10. Prometheus

"The backend exposes request counters and latency metrics. A ServiceMonitor connects it to Prometheus. Here the important check is that every application target is UP."

### 11. Grafana

“Grafana displays actual application requests and latency from Prometheus. I'll generate some traffic and show the dashboard updating in the walkthrough.”

### 12. Learnings and limits

“The main lessons were checking the full request path, handling database conflicts properly and keeping deployment permissions small. This is a classroom app. It still needs authentication, TLS, reliable backups and a highly available database before real use.”

## Live walkthrough

### Codebase

“Here's the project folder. These are the API routes, the database model and the migration. This unique constraint covers the room, date and hour, so concurrent requests can't both reserve the same slot. The tests use their own database. These Dockerfiles run the applications without root, and the frontend has separate build and runtime stages.”

### Push and pipeline

“I'm changing the recording revision in the GitOps values file. That changes the backend Pod annotation without replacing the pinned local image. I'll commit and push it now.”

[Run the Git commands. Open the new Actions run.]

“This is the run for the commit I just pushed. Tests and security checks run before image publication. The images use this commit SHA, and the deployment job verifies the checked images.”

[After completion, show its actual final result. If waiting is edited out, say:]

“I've shortened the waiting time. This is the same run after completion.”

[Only if AWS deployment actually passed:]

“The EKS deployment also passed using the temporary role. It doesn't use a permanent AWS key in the repository.”

### Terraform and AWS

"This is the creation plan and its result. Terraform manages the StudySlot network and EKS resources, and reuses the account's existing GitHub identity provider. In the AWS Console, this is the VPC and its two subnets in separate zones. This is the Active EKS cluster and its worker group. A plan against the current setup should now show no changes."

“The local browser demonstration uses Minikube. The separate GitHub Actions job checks the EKS application. I haven't exposed a public cloud LoadBalancer just for the demo.”

### Argo CD

“Argo CD has picked up the Git change. The application is Synced and Healthy, and the backend rollout has completed. The source is this repository's main branch.”

### Kubernetes and application

“These are the Ready application Pods, internal Services and Ingress. The PostgreSQL volume is Bound. Both the process health and database readiness endpoints respond successfully.”

[Create your own demo booking, try the duplicate, edit, refresh and cancel it.]

“I'll book an available slot. Repeating the same slot returns a conflict. I can change it, refresh to confirm it persisted, and cancel my demo booking. Swagger exposes the corresponding API routes.”

[Run the HTTP integration check.]

“The concurrent check sends two requests for the same slot. The results are one 201 and one 409, and the helper removes its own records afterward.”

### Prometheus

"This is the backend metrics endpoint. Prometheus discovers the backend targets through the ServiceMonitor, and all of them are UP."

### Grafana

“This dashboard uses the same Prometheus data. These are the target count, request activity and latency. The requests from the app demonstration are real traffic, not sample numbers pasted into the dashboard.”

### Cleanup and close

“I've disabled AWS deployment, removed the temporary application volume and destroyed the Terraform lab. This final check confirms the project resources are gone. The source, checks and screenshots remain in the repository. That's the complete StudySlot walkthrough.”

Only use the cleanup line after cleanup actually succeeds. If anything is still running, describe that honestly and complete teardown before leaving.
