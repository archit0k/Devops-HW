# StudySlot demo

Archit Kulkarni · 24BCS10194 · Section A

- [Presentation](presentation.pptx) — twelve slides with actual app, pipeline, AWS, Kubernetes, Argo CD, Prometheus and Grafana evidence.
- [Recording guide](recording-guide.md) — preparation, browser tabs, exact commands, scene order and cleanup.
- [Speaking script](speaking-script.md) — short lines for the slides and live walkthrough.
- [Earlier walkthrough video](walkthrough.mp4) — 7:39 captioned H.264 MP4 using the previous ten-slide deck. It has not been replaced with the new narrated recording. Download it if GitHub does not show an inline player.
- [Captions](walkthrough.srt) and [capture log](capture-log.json).
- [Slide preview](slides.html) — download this folder and open the HTML file locally, or open the individual images in `slides/`.

The earlier MP4 shows slides first, followed by the codebase, a real main-branch change and pipeline, Terraform/AWS, Argo CD, Kubernetes, Prometheus and Grafana. It is an edited, captioned browser walkthrough; waiting periods are shortened. Command-output scenes show saved stdout with matching command/timestamp/exit-code records in [project/evidence](../project/evidence/README.md). The new guide calls for executing those commands during the live recording, rather than describing saved logs as new commands.

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

The earlier AWS lab was removed after capture. The later recording rehearsal is also shut down: its AWS resources were deleted and the local demo stopped with data preserved. Its separate cleanup proof is in [the current rehearsal record](../project/evidence/rehearsal-20261016/README.md), not the older teardown screenshot. Recording setup is paused until the next recording window. No always-on public endpoint is promised.
