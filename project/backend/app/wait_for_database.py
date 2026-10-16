"""Bounded startup wait; never print the database URL or its password."""
import time

from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

from .database import engine


def main():
    for _attempt in range(60):
        try:
            with engine.connect() as connection:
                connection.execute(text("SELECT 1"))
            print("PostgreSQL is ready for migrations.", flush=True)
            return
        except SQLAlchemyError:
            time.sleep(3)
    raise SystemExit("Database was not ready within the startup deadline.")


if __name__ == "__main__":
    main()
