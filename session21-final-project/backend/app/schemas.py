from datetime import date
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

ROOMS = {"Library A": 4, "Library B": 4, "Group Room": 6}


class BookingInput(BaseModel):
    student_name: str = Field(min_length=2, max_length=80)
    roll_no: str = Field(pattern=r"^[A-Za-z0-9]{5,20}$")
    room: Literal["Library A", "Library B", "Group Room"]
    booking_date: date
    start_hour: int = Field(ge=8, le=20)
    attendees: int = Field(ge=1, le=6)


class BookingOutput(BookingInput):
    model_config = ConfigDict(from_attributes=True)
    id: int
