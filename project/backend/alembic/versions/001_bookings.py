"""Create the study-room bookings table."""

import sqlalchemy as sa

from alembic import op

revision = "001_bookings"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "bookings",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("student_name", sa.String(80), nullable=False),
        sa.Column("roll_no", sa.String(20), nullable=False),
        sa.Column("room", sa.String(30), nullable=False),
        sa.Column("booking_date", sa.Date(), nullable=False),
        sa.Column("start_hour", sa.Integer(), nullable=False),
        sa.Column("attendees", sa.Integer(), nullable=False),
        sa.UniqueConstraint("room", "booking_date", "start_hour", name="uq_room_slot"),
        sa.CheckConstraint(
            "start_hour >= 8 AND start_hour <= 20", name="ck_booking_hour"
        ),
        sa.CheckConstraint(
            "attendees >= 1 AND attendees <= 6", name="ck_booking_attendees"
        ),
    )


def downgrade():
    op.drop_table("bookings")
