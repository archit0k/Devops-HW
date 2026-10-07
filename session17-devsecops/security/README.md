# Security gates

Bandit scans the application source (SAST). `pip-audit` checks Python dependencies (SCA). Gitleaks scans Git history and redacts reports. Trivy checks OS and Python packages in the finished image and blocks HIGH/CRITICAL findings. No gate uses `continue-on-error` or ignores CVEs.

The four exact historical instructor sample findings are recorded in the root `.gitleaksignore`; new findings still fail. There are no AWS keys or Kubernetes credentials in this workflow. GitHub's short-lived token has package-write access only in the publishing job.

This is a deliberately small classroom Flask app, not a production web service. The development HTTP server is sufficient for the lab demonstration; a real deployment would add a WSGI server, TLS, authentication, logging controls and rate limits.
