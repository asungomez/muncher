"""The engine every connection to the database is drawn from."""

from sqlalchemy import URL, text
from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine

from muncher_api.config.database import DatabaseSettings


def create_database_engine(settings: DatabaseSettings) -> AsyncEngine:
    """Create the engine, without opening any connection yet."""
    url = URL.create(
        "postgresql+psycopg",
        username=settings.user,
        password=settings.password.get_secret_value(),
        host=settings.host,
        port=settings.port,
        database=settings.name,
    )
    return create_async_engine(url, pool_pre_ping=True)


async def check_database_connection(engine: AsyncEngine) -> None:
    """Fail now, rather than on the first request, if the database is unreachable."""
    async with engine.connect() as connection:
        await connection.execute(text("SELECT 1"))
