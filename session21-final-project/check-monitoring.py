"""Assert live Prometheus samples rather than just a dashboard configuration."""
import json
import math
import time
import urllib.parse
import urllib.request

queries = {
    "TaskBoard scrape UP": 'sum(up{namespace="taskboard"})',
    "HTTP requests": 'sum(http_requests_total{namespace="taskboard"})',
    "Available backend replicas": 'kube_deployment_status_replicas_available{namespace="taskboard",deployment="taskboard-taskboard-backend"}',
    "Backend CPU rate": 'sum(rate(container_cpu_usage_seconds_total{namespace="taskboard",container="backend"}[2m]))',
    "Request latency p95": 'histogram_quantile(0.95,sum by(le)(rate(http_request_duration_seconds_bucket{namespace="taskboard"}[2m])))',
    "5xx error rate": 'sum(rate(http_requests_total{namespace="taskboard",status="5xx"}[2m])) or vector(0)',
}
for label, query in queries.items():
    for attempt in range(24):
        url = "http://localhost:9090/api/v1/query?" + urllib.parse.urlencode({"query":query})
        result = json.load(urllib.request.urlopen(url, timeout=20))
        samples = result["data"]["result"]
        if samples and all(math.isfinite(float(sample["value"][1])) for sample in samples):
            break
        time.sleep(5)
    assert result["status"] == "success" and samples, (label, result)
    assert all(math.isfinite(float(sample["value"][1])) for sample in samples), (label, samples)
    print(label, json.dumps(samples))
    if label in ("TaskBoard scrape UP", "HTTP requests", "Available backend replicas"):
        assert float(samples[0]["value"][1]) > 0
targets = json.load(urllib.request.urlopen("http://localhost:9090/api/v1/targets", timeout=20))
taskboard_targets = [target for target in targets["data"]["activeTargets"]
                    if target["labels"].get("namespace") == "taskboard"]
assert taskboard_targets and all(target["health"] == "up" for target in taskboard_targets)
for target in taskboard_targets:
    print("Scrape target:", target["scrapeUrl"], target["health"], "lastError:", target["lastError"])
grafana = json.load(urllib.request.urlopen("http://localhost:3001/api/health", timeout=20))
assert grafana["database"] == "ok"
print("Grafana health:", json.dumps(grafana))
