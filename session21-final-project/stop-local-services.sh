#!/usr/bin/env bash
# Stop the homework container services after the read-only resource check.
set -euo pipefail
set -x
systemctl stop docker.socket docker.service containerd.service
systemctl is-active docker.service containerd.service || true
pgrep -af '^bash session21-final-project/forward-local.sh$' || true
ss -ltnp | awk 'NR == 1 || $4 ~ /:(3000|3001|8000|9090)$/'
