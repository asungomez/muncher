"""The port through which the application reads and stores recipes."""

from typing import Protocol

from muncher_api.domain.recipe import Recipe


class RecipeRepository(Protocol):
    """Where the recipes are kept, whatever the storage behind it."""

    async def list_recipes(self) -> list[Recipe]:
        """Return every recipe."""
