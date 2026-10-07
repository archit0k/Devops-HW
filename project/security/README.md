# Security checks

The pipeline blocks image publication when tests, SAST, dependency checks, secret scanning or either image scan fails. There is no `continue-on-error` and no CVE allowlist.

The first full-history scan found four references to the instructor's literal demo password in the old Session 12 commit, not AWS/GitHub credentials. Current Secret templates are empty and the helper generates a disposable runtime password. `.gitleaksignore` records only the four **exact historical fingerprints**; it does not exclude directories, rules, new commits or real credentials. Published history is left unchanged.

- Ruff checks obvious code mistakes. Bandit is the Python SAST check.
- `pip-audit` checks the resolved Python dependencies; `npm audit` checks frontend dependencies.
- Gitleaks scans the whole Git history with redacted output. Credentials belong in ignored local files or Kubernetes Secrets, never the repository.
- Trivy checks OS packages and application dependencies in **both** final runtime images. Any HIGH or CRITICAL finding returns exit code 1 before GHCR push.

A clean scan means no matching HIGH/CRITICAL advisory was found in that image against the database used for that run. It does not prove there are no lower-severity, undisclosed or application-level vulnerabilities. Image tags use the commit SHA so the deployed code can be traced back to its tests and scans.

The app intentionally has no authentication; only disposable classroom data belongs in it. The local backend port binds to loopback, the database has no published port, and containers run without root. The cloud demo will be short-lived and removed after verification.
