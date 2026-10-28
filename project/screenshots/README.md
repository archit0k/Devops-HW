# StudySlot screenshots

[Back to the project](../README.md)

Screenshots from 16 October 2026. Command-output images use saved lab output.

| File | What it shows |
| --- | --- |
| [application.jpg](application.jpg), [mobile.jpg](mobile.jpg) | Booking UI at desktop and mobile widths |
| [tests.jpg](tests.jpg) | All 16 API tests passing |
| [commits.jpg](commits.jpg) | Twelve commits recorded on 16 October |
| [compose.jpg](compose.jpg) | Container/HTTP checks and non-root users |
| [pipeline.jpg](pipeline.jpg) | [Run 38894261034](https://github.com/archit0k/Devops-HW/actions/runs/38894261034), all six jobs green |
| [security-backend.jpg](security-backend.jpg), [security-frontend.jpg](security-frontend.jpg) | Recorded Trivy HIGH/CRITICAL scan summaries |
| [aws-vpc.jpg](aws-vpc.jpg), [aws-eks.jpg](aws-eks.jpg) | Two-zone VPC and active EKS cluster |
| [terraform-destroy.jpg](terraform-destroy.jpg) | Completion of the earlier 26-resource destroy, exit code 0 |
| [kubernetes.jpg](kubernetes.jpg), [storage.jpg](storage.jpg) | Workload resources and PostgreSQL persistence check |
| [argocd.jpg](argocd.jpg) | Application Synced and Healthy |
| [prometheus.jpg](prometheus.jpg), [grafana.jpg](grafana.jpg) | Two targets UP and application traffic/replica metrics |

The [later six-job run](https://github.com/archit0k/Devops-HW/actions/runs/38943691357) also passed. Its cleanup removed 25 resources; it reused an existing OIDC provider.
