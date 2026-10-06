"""The environment Alembic runs every migration command in.

It is a second entry point beside `main.py`, so it reads the database settings
itself, from the same DATABASE_* variables, and connects through the same
engine the API uses.
"""

import asyncio
import logging

from alembic import context
from alembic.util import CommandError
from sqlalchemy import Connection

from muncher_api.adapters.persistence.sql.engine import create_database_engine
from muncher_api.adapters.persistence.sql.metadata import metadata
from muncher_api.config.base import read_required_settings
from muncher_api.config.database import DatabaseSettings


def run_migrations(connection: Connection) -> None:
    """Run the migrations Alembic selected over an open connection."""
    context.configure(connection=connection, target_metadata=metadata)
    with context.begin_transaction():
        context.run_migrations()


async def run_migrations_online() -> None:
    """Connect to the database and run the migrations against it."""
    engine = create_database_engine(read_required_settings(DatabaseSettings))
    try:
        async with engine.connect() as connection:
            await connection.run_sync(run_migrations)
    finally:
        await engine.dispose()


# Without an alembic.ini there is no logging configuration to load, and Alembic
# would apply each migration without a word.
logging.basicConfig(format="%(levelname)-5.5s [%(name)s] %(message)s")
logging.getLogger("alembic").setLevel(logging.INFO)

# Generating SQL offline is not supported; running online instead would apply
# the migrations that were only meant to be printed.
if context.is_offline_mode():
    message = "Offline mode (--sql) is not supported."
    raise CommandError(message)

asyncio.run(run_migrations_online())
