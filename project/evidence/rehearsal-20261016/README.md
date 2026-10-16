# Recording rehearsal, 16 October 2026

This is a new recording preparation, separate from the earlier completed AWS lab. The original evidence remains dated and unchanged.

## Status

- Local Minikube has resumed with its existing database preserved.
- [Fresh tests and code/dependency checks](tests.txt) passed: 16 tests, Ruff, Bandit and pip-audit.
- [Local end-to-end checks](verify-local-passing.txt) passed: real PostgreSQL CRUD/conflicts, healthy routing, Prometheus scrapes/queries, Argo CD Synced/Healthy and working CPU metrics.
- The first [startup verification](verify-local.txt) caught temporary readiness/metrics problems. It is retained as a failed attempt, not a passing result. Ingress and Metrics Server recovered after restart, and the later verification passed.
- The Grafana replica panel now aggregates its metric so stale/restarted kube-state-metrics series do not produce duplicate stat values.
- [Initial Terraform plan](terraform-plan.txt): 26 intended resources. The [first apply](terraform-apply.txt) created the network, cluster and workers but correctly failed on a GitHub OIDC provider that another project already owned. The provider is now reused without importing or modifying it. The [repair plan](terraform-access-plan.txt) adds only four missing StudySlot access resources; [its apply](terraform-access-apply.txt) is recorded separately. The resulting lab manages 25 resources, VPC `vpc-0a4ae82a738379dd9`. This rehearsal's cleanup is not proven by the earlier lab's cleanup file.
- The [fresh AWS bootstrap](https://github.com/archit0k/Devops-HW/actions/runs/38942882934) passed. [Access restriction](terraform-restrict.txt) then replaced cluster administration with deployment permissions only in the `studyslot` namespace. The application, cluster and workers are currently available for recording, not yet torn down.
- A new personally narrated live video has not yet replaced the earlier captioned MP4. Follow the [recording guide](../../../demo/recording-guide.md) and [speaking script](../../../demo/speaking-script.md).

## Fresh browser captures

These are browser screenshots of the actual running services, not mockups. The rehearsal booking used Archit's own synthetic details and was cancelled after checking the duplicate-slot response.

### Application and conflict handling

![StudySlot booking](desktop-browser.jpg)

![Duplicate slot rejected](booking-conflict.jpg)

![Only the rehearsal booking cancelled](booking-cancelled.jpg)

### GitOps

![Argo CD synchronized and healthy](argocd-synced.jpg)

### Monitoring

![StudySlot targets](prometheus-targets.jpg)

![Real application metrics](grafana-live.jpg)

### New AWS VPC

![Two public subnets in separate zones](aws-vpc-map.jpg)

![New EKS cluster Active](aws-eks.jpg)

## Recording material

Use the current slide deck and command guide for the new recording. Keep the microphone audible, commands readable and all login/Secret/state content off camera. Record the actual push and its matching pipeline. No form is submitted automatically.
