from datetime import date

from sqlalchemy import CheckConstraint, Date, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from .database import Base


class Booking(Base):
    __tablename__ = "bookings"
    __table_args__ = (
        UniqueConstraint("room", "booking_date", "start_hour", name="uq_room_slot"),
        CheckConstraint("start_hour >= 8 AND start_hour <= 20", name="ck_booking_hour"),
        CheckConstraint(
            "attendees >= 1 AND attendees <= 6", name="ck_booking_attendees"
        ),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    student_name: Mapped[str] = mapped_column(String(80))
    roll_no: Mapped[str] = mapped_column(String(20))
    room: Mapped[str] = mapped_column(String(30))
    booking_date: Mapped[date] = mapped_column(Date)
    start_hour: Mapped[int] = mapped_column(Integer)
    attendees: Mapped[int] = mapped_column(Integer)
