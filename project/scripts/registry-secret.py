"""Use the runner's expiring GitHub token for this namespace's private images."""
import base64
import json
import os
import subprocess

token = os.environ["REGISTRY_TOKEN"]
auth = base64.b64encode(f"archit0k:{token}".encode()).decode()
config = json.dumps({"auths": {"ghcr.io": {"auth": auth}}})
document = {"apiVersion": "v1", "kind": "Secret", "type": "kubernetes.io/dockerconfigjson",
            "metadata": {"name": "ghcr", "namespace": "studyslot"},
            "data": {".dockerconfigjson": base64.b64encode(config.encode()).decode()}}
subprocess.run(["kubectl", "apply", "-f", "-"], input=json.dumps(document), text=True, check=True)
