import logging
import time
import uuid
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest
from sqlalchemy import select, text
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.orm import Session

from .database import get_db
from .models import Booking
from .schemas import ROOMS, BookingInput, BookingOutput

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger("studyslot")
app = FastAPI(title="StudySlot", version="1.0.0")
DatabaseSession = Annotated[Session, Depends(get_db)]
requests_total = Counter(
    "studyslot_http_requests_total", "HTTP responses", ["method", "route", "status"]
)
request_seconds = Histogram(
    "studyslot_http_request_duration_seconds", "Request latency", ["route"]
)


@app.middleware("http")
async def observe_request(request, call_next):
    started = time.perf_counter()
    request_id = str(uuid.uuid4())
    response = await call_next(request)
    route = getattr(request.scope.get("route"), "path", "unmatched")
    if route != "/metrics":
        elapsed = time.perf_counter() - started
        requests_total.labels(request.method, route, str(response.status_code)).inc()
        request_seconds.labels(route).observe(elapsed)
        logger.info(
            "request_id=%s method=%s route=%s status=%s duration=%.4f",
            request_id,
            request.method,
            route,
            response.status_code,
            elapsed,
        )
    response.headers["X-Request-ID"] = request_id
    return response


@app.get("/health")
def health():
    return {"status": "ok", "app": "StudySlot", "student": "Archit Kulkarni"}


@app.get("/ready")
def ready(db: DatabaseSession):
    try:
        db.execute(text("SELECT 1"))
    except SQLAlchemyError as error:
        raise HTTPException(503, "Database unavailable") from error
    return {"status": "ready"}


@app.get("/metrics", include_in_schema=False)
def metrics():
    return Response(generate_latest(), headers={"Content-Type": CONTENT_TYPE_LATEST})


@app.get("/api/rooms")
def rooms():
    return [{"name": name, "capacity": capacity} for name, capacity in ROOMS.items()]


@app.get("/api/bookings", response_model=list[BookingOutput])
def list_bookings(db: DatabaseSession):
    return db.scalars(
        select(Booking).order_by(Booking.booking_date, Booking.start_hour, Booking.id)
    ).all()


def find_booking(booking_id: int, db: Session):
    booking = db.get(Booking, booking_id)
    if booking is None:
        raise HTTPException(404, "Booking not found")
    return booking


@app.get("/api/bookings/{booking_id}", response_model=BookingOutput)
def get_booking(booking_id: int, db: DatabaseSession):
    return find_booking(booking_id, db)


def save_booking(booking: Booking, data: BookingInput, db: Session):
    if data.attendees > ROOMS[data.room]:
        raise HTTPException(422, "Too many people for this room")
    for field, value in data.model_dump().items():
        setattr(booking, field, value)
    db.add(booking)
    try:
        db.commit()
    except IntegrityError as error:
        db.rollback()
        raise HTTPException(409, "This room is already booked for that hour") from error
    db.refresh(booking)
    return booking


@app.post("/api/bookings", response_model=BookingOutput, status_code=201)
def create_booking(data: BookingInput, db: DatabaseSession):
    return save_booking(Booking(), data, db)


@app.put("/api/bookings/{booking_id}", response_model=BookingOutput)
def update_booking(booking_id: int, data: BookingInput, db: DatabaseSession):
    return save_booking(find_booking(booking_id, db), data, db)


@app.delete("/api/bookings/{booking_id}", status_code=204)
def delete_booking(booking_id: int, db: DatabaseSession):
    db.delete(find_booking(booking_id, db))
    db.commit()
    return Response(status_code=204)
