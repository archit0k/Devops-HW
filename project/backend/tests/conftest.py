import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session
from sqlalchemy.pool import StaticPool

from app.database import Base, get_db
from app.main import app


@pytest.fixture
def client():
    # Each test gets an empty in-memory database. Never touches DATABASE_URL.
    test_engine = create_engine(
        "sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool
    )
    Base.metadata.create_all(test_engine)

    def test_db():
        with Session(test_engine) as session:
            yield session

    app.dependency_overrides[get_db] = test_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()
    test_engine.dispose()


@pytest.fixture
def booking():
    return {
        "student_name": "Archit Kulkarni",
        "roll_no": "24BCS10194",
        "room": "Library A",
        "booking_date": "2026-12-01",
        "start_hour": 10,
        "attendees": 2,
    }
