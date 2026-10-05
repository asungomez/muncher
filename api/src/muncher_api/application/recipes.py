"""The use cases about recipes."""

from muncher_api.domain.recipe import Recipe
from muncher_api.ports.persistence.recipe_repository import RecipeRepository


class RecipeService:
    """Answers what the driving adapters ask about recipes."""

    def __init__(self, recipe_repository: RecipeRepository) -> None:
        """Work against whichever repository the composition root provides."""
        self._recipe_repository = recipe_repository

    async def list_recipes(self) -> list[Recipe]:
        """Return the full collection of recipes."""
        return await self._recipe_repository.list_recipes()
