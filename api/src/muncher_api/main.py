"""The API application, and the composition root that assembles it.

This is the only module that knows the concrete adapters: it reads the
settings, builds the driven adapters, hands them to the use cases through the
ports, and gives the use cases to the routers. Everything else depends on
interfaces, so swapping an adapter is a change here and nowhere else.

FastAPI derives the OpenAPI specification from the type annotations of the
endpoints, so the schema served at /openapi.json and the documentation page at
/docs are both generated from the signatures and models the routers declare.
"""

import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from muncher_api.adapters.http.recipes import create_recipes_router
from muncher_api.adapters.persistence.memory.recipe_repository import (
    InMemoryRecipeRepository,
)
from muncher_api.adapters.persistence.sql.engine import (
    check_database_connection,
    create_database_engine,
)
from muncher_api.application.recipes import RecipeService
from muncher_api.config.base import read_settings

logger = logging.getLogger(__name__)

settings = read_settings()

database_engine = (
    None if settings.database is None else create_database_engine(settings.database)
)

recipe_service = RecipeService(InMemoryRecipeRepository())


@asynccontextmanager
async def lifespan(_app: FastAPI) -> AsyncIterator[None]:
    """Check the database on startup and release its connections on shutdown."""
    if database_engine is None:
        logger.warning("No DATABASE_* variable is set; starting without a database")
        yield
        return

    await check_database_connection(database_engine)
    yield
    await database_engine.dispose()


app = FastAPI(
    title="Muncher API",
    version="0.1.0",
    summary="End-to-end management of cooking recipes.",
    lifespan=lifespan,
)

app.include_router(create_recipes_router(recipe_service))
