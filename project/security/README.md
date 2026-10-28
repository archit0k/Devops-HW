# Security checks

Archit Kulkarni | 24BCS10194 | Section A

[Back to StudySlot](../README.md)

The pipeline blocks image publication when tests, SAST, dependency checks, secret scanning or either image scan fails. There is no `continue-on-error` and no CVE allowlist.

`.gitleaksignore` contains four exact fingerprints for an old Session 12 sample password. New findings fail the scan. Current Secret templates are empty; the helper creates a runtime password.

- Ruff checks obvious code mistakes. Bandit is the Python SAST check.
- `pip-audit` checks the resolved Python dependencies; `npm audit` checks frontend dependencies.
- Gitleaks scans the whole Git history with redacted output. Credentials belong in ignored local files or Kubernetes Secrets, never the repository.
- Trivy checks OS packages and application dependencies in **both** final runtime images. Any HIGH or CRITICAL finding returns exit code 1 before GHCR push.

Image tags use the commit SHA to link deployed code to its tests and scans. The local backend binds to loopback, the database has no published port, and the application containers run without root.

Trivy results: [backend](../screenshots/security-backend.jpg) and [frontend](../screenshots/security-frontend.jpg). All six jobs passed in [this run](https://github.com/archit0k/Devops-HW/actions/runs/38943691357).
