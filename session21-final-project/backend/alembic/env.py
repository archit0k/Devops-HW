from sqlalchemy import create_engine, text

from alembic import context
from app import models  # noqa: F401
from app.database import DATABASE_URL, Base

if context.is_offline_mode():
    context.configure(
        url=DATABASE_URL, target_metadata=Base.metadata, literal_binds=True
    )
    with context.begin_transaction():
        context.run_migrations()
else:
    engine = create_engine(DATABASE_URL)
    with engine.connect() as connection:
        # Two backend replicas can start together. Serialize PostgreSQL migrations.
        if connection.dialect.name == "postgresql":
            connection.execute(text("SELECT pg_advisory_lock(2410194)"))
            connection.commit()
        context.configure(connection=connection, target_metadata=Base.metadata)
        with context.begin_transaction():
            context.run_migrations()
