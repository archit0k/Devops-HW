# Security gates

[Back to Session 17](../README.md)

| Gate | Checks |
| --- | --- |
| Bandit | Risky Python source patterns |
| pip-audit | Known vulnerable dependencies |
| Gitleaks | Secrets in Git history |
| Trivy | OS/application packages in the finished image |

Bandit scans the application source (SAST). `pip-audit` checks Python dependencies (SCA). Gitleaks scans Git history and redacts reports. Trivy checks OS and Python packages in the finished image and blocks HIGH/CRITICAL findings. No gate uses `continue-on-error` or ignores CVEs.

The root `.gitleaksignore` contains four exact fingerprints for an old sample password; new findings still fail. GitHub's short-lived token has package-write access only in the publishing job.
