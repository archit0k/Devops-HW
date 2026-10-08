"""Check the live classroom app through its loopback Ingress port-forward."""
import json
import urllib.error
import urllib.request

base = "http://localhost:3000"

def request(method, path, data=None, expected=200):
    body = None if data is None else json.dumps(data).encode()
    req = urllib.request.Request(base + path, data=body, method=method,
                                 headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=20) as response:
            code, raw = response.status, response.read()
    except urllib.error.HTTPError as error:
        code, raw = error.code, error.read()
    print(f"{method} {path}: HTTP {code}")
    assert code == expected, (code, raw)
    return json.loads(raw) if raw else None

print("Archit Kulkarni | 24BCS10194 | TaskBoard Ingress CRUD")
with urllib.request.urlopen(base, timeout=20) as response:
    assert response.status == 200 and b'<div id="root">' in response.read()
print("GET /: React frontend HTTP 200")
request("GET", "/api/tasks")
task = request("POST", "/api/tasks", {"title":"Check CRUD - 24BCS10194", "assignee":"Archit Kulkarni",
               "description":"Temporary API check", "priority":"HIGH"}, expected=201)
print(json.dumps(task, indent=2))
task_id = task["id"]
updated = request("PUT", f"/api/tasks/{task_id}", {"status":"DONE"})
assert updated["status"] == "DONE"
assert request("GET", f"/api/tasks/{task_id}")["assignee"] == "Archit Kulkarni"
print(json.dumps(request("GET", "/api/tasks/stats"), indent=2))
request("DELETE", f"/api/tasks/{task_id}", expected=204)
request("GET", f"/api/tasks/{task_id}", expected=404)
saved = next((task for task in request("GET", "/api/tasks")
              if task["title"] == "Verify TaskBoard PVC - 24BCS10194"), None)
if saved is None:
    saved = request("POST", "/api/tasks", {"title":"Verify TaskBoard PVC - 24BCS10194",
                    "assignee":"Archit Kulkarni", "description":"Must remain after PostgreSQL Pod replacement"}, expected=201)
print("Persistence test row:", json.dumps(saved))
for endpoint in ("health", "ready", "docs", "metrics"):
    with urllib.request.urlopen(f"http://localhost:8000/{endpoint}", timeout=20) as response:
        assert response.status == 200
    print(f"Backend /{endpoint}: HTTP 200")
print("CRUD and API checks passed.")
