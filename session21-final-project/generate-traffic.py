"""Small, bounded HTTP load to give Prometheus real samples for the demo."""
import time
import urllib.request

print("TaskBoard: one task-list request per second for 360 seconds.")
for count in range(360):
    with urllib.request.urlopen("http://localhost:3000/api/tasks", timeout=20) as response:
        assert response.status == 200
        response.read()
    if count % 30 == 0:
        print(f"Successful requests: {count + 1}", flush=True)
    time.sleep(1)
print("360 requests completed; traffic generator stopped.")
