def test_health_and_database_ready(client):
    assert client.get("/health").json()["status"] == "ok"
    assert client.get("/ready").status_code == 200


def test_rooms_and_empty_list(client):
    assert len(client.get("/api/rooms").json()) == 3
    assert client.get("/api/bookings").json() == []


def test_create_get_and_list(client, booking):
    created = client.post("/api/bookings", json=booking)
    assert created.status_code == 201
    data = created.json()
    assert data["student_name"] == "Archit Kulkarni"
    assert client.get(f"/api/bookings/{data['id']}").json() == data
    assert len(client.get("/api/bookings").json()) == 1


def test_double_booking_is_rejected(client, booking):
    assert client.post("/api/bookings", json=booking).status_code == 201
    assert client.post("/api/bookings", json=booking).status_code == 409


def test_another_room_can_use_same_hour(client, booking):
    client.post("/api/bookings", json=booking)
    booking["room"] = "Library B"
    assert client.post("/api/bookings", json=booking).status_code == 201


def test_update_changes_booking(client, booking):
    booking_id = client.post("/api/bookings", json=booking).json()["id"]
    booking["start_hour"] = 12
    response = client.put(f"/api/bookings/{booking_id}", json=booking)
    assert response.status_code == 200
    assert response.json()["start_hour"] == 12


def test_conflicting_update_keeps_original_slot(client, booking):
    first = client.post("/api/bookings", json=booking).json()["id"]
    booking["start_hour"] = 11
    second = client.post("/api/bookings", json=booking).json()["id"]
    booking["start_hour"] = 10
    assert client.put(f"/api/bookings/{second}", json=booking).status_code == 409
    assert client.get(f"/api/bookings/{second}").json()["start_hour"] == 11
    assert client.get(f"/api/bookings/{first}").json()["start_hour"] == 10


def test_delete_frees_slot(client, booking):
    booking_id = client.post("/api/bookings", json=booking).json()["id"]
    assert client.delete(f"/api/bookings/{booking_id}").status_code == 204
    assert client.get(f"/api/bookings/{booking_id}").status_code == 404
    assert client.post("/api/bookings", json=booking).status_code == 201


def test_missing_booking(client, booking):
    assert client.get("/api/bookings/999").status_code == 404
    assert client.put("/api/bookings/999", json=booking).status_code == 404
    assert client.delete("/api/bookings/999").status_code == 404


def test_capacity_validation(client, booking):
    booking["attendees"] = 5
    assert client.post("/api/bookings", json=booking).status_code == 422


def test_invalid_hour_and_roll_number(client, booking):
    booking["start_hour"] = 23
    assert client.post("/api/bookings", json=booking).status_code == 422
    booking["start_hour"] = 10
    booking["roll_no"] = "bad value!"
    assert client.post("/api/bookings", json=booking).status_code == 422


def test_metrics_and_request_id(client):
    response = client.get("/health")
    assert response.headers["X-Request-ID"]
    metrics = client.get("/metrics")
    assert metrics.status_code == 200
    assert "studyslot_http_requests_total" in metrics.text
