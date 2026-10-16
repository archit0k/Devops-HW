"""Small, bounded GET-only traffic sample for the local recording dashboard."""
import argparse
import time
import urllib.request

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--seconds", type=int, default=180)
args = parser.parse_args()
if not 1 <= args.seconds <= 600:
    parser.error("Use between 1 and 600 seconds")
deadline = time.monotonic() + args.seconds
count = 0
while time.monotonic() < deadline:
    for path in ("/api/rooms", "/api/bookings"):
        with urllib.request.urlopen("http://localhost:3000" + path, timeout=10) as response:
            assert response.status == 200
            response.read()
        count += 1
    time.sleep(0.5)
print(f"Completed {count} successful local GET requests. No bookings were changed.")
