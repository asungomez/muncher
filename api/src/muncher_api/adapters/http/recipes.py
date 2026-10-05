"""Recipes endpoints."""

from fastapi import APIRouter

from muncher_api.application.recipes import RecipeService
from muncher_api.domain.recipe import Recipe


def create_recipes_router(recipe_service: RecipeService) -> APIRouter:
    """Build the recipes endpoints on top of the service that answers them."""
    router = APIRouter(prefix="/recipes", tags=["recipes"])

    @router.get("", summary="List the recipes")
    async def list_recipes() -> list[Recipe]:
        """Return the full collection of recipes."""
        return await recipe_service.list_recipes()

    return router
