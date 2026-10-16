"""Real HTTP CRUD and concurrent-booking checks against a disposable demo."""
import concurrent.futures
import json
import os
import urllib.error
import urllib.request
from datetime import date, timedelta

base = os.getenv("API_BASE_URL", "http://localhost:3000").rstrip("/")
backend = os.getenv("BACKEND_URL", "http://localhost:8000").rstrip("/")


def request(method, path, data=None, expected=200, origin=None):
    payload = None if data is None else json.dumps(data).encode()
    req = urllib.request.Request(
        (origin or base) + path, data=payload, method=method,
        headers={"Content-Type": "application/json"},
    )
    try:
        response = urllib.request.urlopen(req, timeout=30)
    except urllib.error.HTTPError as error:
        response = error
    with response:
        status = response.status
        body = response.read().decode()
        print(f"{method} {path} -> {status}: {body[:500]}", flush=True)
    assert status == expected, (status, expected, body)
    return json.loads(body) if body and path.startswith("/api/") else body


def main():
    request("GET", "/health", origin=backend)
    request("GET", "/ready", origin=backend)
    assert "StudySlot" in request("GET", "/")
    assert len(request("GET", "/api/rooms")) == 3
    request("GET", "/api/bookings")
    request("GET", "/docs", origin=backend)
    record = {
        "student_name": "Archit Kulkarni", "roll_no": "24BCS10194",
        "room": "Group Room", "booking_date": "2099-10-16",
        "start_hour": 19, "attendees": 3,
    }
    created_ids = []
    try:
        created = request("POST", "/api/bookings", record, 201)
        created_ids.append(created["id"])
        path = f"/api/bookings/{created['id']}"
        assert request("GET", path)["roll_no"] == "24BCS10194"
        request("POST", "/api/bookings", record, 409)
        updated = request("PUT", path, {**record, "start_hour": 20})
        assert updated["start_hour"] == 20
        request("DELETE", path, expected=204)
        created_ids.remove(created["id"])
        request("GET", path, expected=404)

        # Both real requests race for the same PostgreSQL UNIQUE key.
        def compete(_index):
            req = urllib.request.Request(base + "/api/bookings", data=json.dumps(record).encode(),
                                         headers={"Content-Type": "application/json"}, method="POST")
            try:
                with urllib.request.urlopen(req, timeout=30) as response:
                    return response.status, json.loads(response.read())
            except urllib.error.HTTPError as error:
                return error.code, json.loads(error.read())

        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
            results = list(pool.map(compete, range(2)))
        created_ids.extend(body["id"] for status, body in results if status == 201)
        print("Concurrent POST results:", json.dumps(results), flush=True)
        assert sorted(status for status, _body in results) == [201, 409]
        request("POST", "/api/bookings", {**record, "student_name": "   "}, 422)
        request("POST", "/api/bookings", {**record, "room": "Library A", "attendees": 5}, 422)
        metrics = request("GET", "/metrics", origin=backend)
        assert "studyslot_http_requests_total" in metrics
    finally:
        for booking_id in created_ids:
            request("DELETE", f"/api/bookings/{booking_id}", expected=204)

    if os.getenv("SEED_DEMO") == "1":
        day = (date.today() + timedelta(days=1)).isoformat()
        for room, hour, count in [("Library A", 10, 2), ("Group Room", 14, 4)]:
            request("POST", "/api/bookings", {
                **record, "room": room, "booking_date": day,
                "start_hour": hour, "attendees": count,
            }, 201)
    print("StudySlot CRUD, validation, metrics and concurrent PostgreSQL booking checks passed.")


if __name__ == "__main__":
    main()
