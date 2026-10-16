# StudySlot demo

Archit Kulkarni · 24BCS10194 · Section A

- [Presentation](presentation.pptx) — ten slides covering the app, architecture, stack, tests, CI/CD, AWS, Kubernetes/GitOps, monitoring and learnings.
- [Walkthrough video](walkthrough.mp4) — 7:39 captioned H.264 MP4. Download it if GitHub does not show an inline player.
- [Captions](walkthrough.srt) and [capture log](capture-log.json).
- [Slide preview](slides.html) — download this folder and open the HTML file locally, or open the individual images in `slides/`.

The slides come first, followed by the codebase, a real main-branch change and pipeline, Terraform/AWS, Argo CD, Kubernetes, Prometheus and Grafana. This is an edited, captioned browser walkthrough; waiting periods are shortened. Command-output scenes show saved stdout with matching command/timestamp/exit-code records in [project/evidence](../project/evidence/README.md).

The recorded [push pipeline](https://github.com/archit0k/Devops-HW/actions/runs/38894261034) finishes with all six jobs green. Its first AWS attempt exposed a missing ServiceMonitor permission; the failed job was rerun after adding a namespace-only Role. The video shows that issue and the final passing result. The [subsequent pipeline](https://github.com/archit0k/Devops-HW/actions/runs/38894715964) also passed all six jobs.

## Chapters

| Time | Topic |
| --- | --- |
| 0:00 | Ten presentation slides |
| 2:00 | Codebase, database constraint and tests |
| 2:54 | Main-branch change and CI/CD, including the permission fix |
| 4:18 | Terraform plan/apply and AWS VPC/EKS |
| 5:17 | Argo CD Synced/Healthy |
| 5:33 | Kubernetes resources, Ingress app and persistence |
| 6:33 | Prometheus targets UP |
| 6:49 | Live Grafana metrics |
| 7:07 | Terraform destroy and leftover checks |

The AWS lab was temporary and has been removed. Local demo services are stopped; their PVC and an ignored SQL backup are preserved. The screenshots and video record the actual running lab before cleanup, not an always-on public endpoint.
