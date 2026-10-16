"""Create a runtime-only database Secret without printing credentials."""
import base64
import json
import secrets
import subprocess

namespace = "studyslot"
subprocess.run(["kubectl", "apply", "-f", "project/k8s/namespace.yaml"], check=True)
existing = subprocess.run(["kubectl", "get", "secret", "studyslot-database", "-n", namespace],
                          stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
if existing.returncode:
    password = secrets.token_hex(24)
    fields = {"password": password,
              "url": f"postgresql+psycopg://studyslot:{password}@postgres:5432/studyslot"}
    document = {"apiVersion": "v1", "kind": "Secret",
                "metadata": {"name": "studyslot-database", "namespace": namespace},
                "data": {key: base64.b64encode(value.encode()).decode() for key, value in fields.items()}}
    subprocess.run(["kubectl", "apply", "-f", "-"], input=json.dumps(document), text=True, check=True)
else:
    print("Reusing the existing database Secret; values are not displayed.")
