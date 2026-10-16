#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../backend"
venv_path=${STUDYSLOT_TEST_VENV:-/tmp/studyslot-tests}
python3 -m venv "$venv_path"
source "$venv_path/bin/activate"
python -m pip install --disable-pip-version-check -r requirements-dev.txt
set -x
pytest -v
ruff check app tests alembic
bandit -r app -ll
pip-audit -r requirements.txt
