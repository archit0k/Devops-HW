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

## Verification

The labs use Docker Engine in Ubuntu WSL; Docker Desktop is not needed. Local Kubernetes commands use `minikube kubectl --` to match the cluster's version. Sessions 1–20 have execution records and screenshots linked from their READMEs; the local link check passed. Session 21 also has a passing test/build/scan/publish/deploy pipeline and a successful EKS Terraform apply followed by cleanup. Its live Ingress, HPA, monitoring and troubleshooting checks are still unfinished. Work is paused for a non-root AWS access decision; the Session 21 README lists the remaining checks.

The separate [StudySlot project](project/README.md) is paused. Its code and existing checks are preserved in `project/`; it is not the Session 21 assignment. Assignment verification records are linked from the individual READMEs.

## Course and submission

Requirements come from the instructor's [devops-heros repository](https://github.com/Nency-Ravaliya/devops-heros) and its linked official homework document. Personal notes are reference material, not extra assignment titles.

The [Section A form](https://forms.gle/ydjAJcwxjpjBXgxB8) asks for GitHub links to the individual README files. Nothing has been submitted. Cloud resources are temporary and the homework spending cap is $30.
