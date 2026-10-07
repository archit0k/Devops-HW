import pytest
from app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    return app.test_client()


def test_health(client):
    assert client.get("/health").json["status"] == "ok"


def test_home(client):
    assert b"24BCS10194" in client.get("/").data


def test_greet(client):
    assert client.get("/api/greet/Archit").json["message"] == "Hello, Archit!"


def test_add(client):
    assert client.post("/api/add", json={"a": 8, "b": 4}).json["result"] == 12


def test_negative_and_float(client):
    assert client.post("/api/add", json={"a": -1, "b": 2.5}).json["result"] == 1.5


def test_bad_input(client):
    assert client.post("/api/add", json={"a": "8", "b": 4}).status_code == 400


def test_missing_input(client):
    assert client.post("/api/add").status_code == 400


def test_unknown_route(client):
    assert client.get("/missing").status_code == 404
