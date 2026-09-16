"""The API application.

FastAPI derives the OpenAPI specification from the type annotations of the
endpoints, so nothing here is written twice: the schema served at
/openapi.json and the documentation page at /docs are both generated from the
signatures and models the routers declare.
"""

from fastapi import FastAPI

from muncher_api import recipes

app = FastAPI(
    title="Muncher API",
    version="0.1.0",
    summary="End-to-end management of cooking recipes.",
)

app.include_router(recipes.router)
