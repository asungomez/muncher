"""Recipes kept in the memory of the process.

The recipes table does not exist yet, so the collection is fixed here: the same
one the front-end used to hardcode in its home page. This adapter goes once the
SQL one can serve recipes.
"""

from muncher_api.domain.recipe import Pill, Recipe

RECIPES = (
    Recipe(
        id="1",
        name="Bol de verduras frescas",
        description=(
            "Un bol colorido lleno de verduras frescas, granos y una deliciosa"
            " vinagreta."
        ),
        image_url=(
            "https://images.unsplash.com/photo-1546069901-ba9599a7e63c"
            "?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8"
            "&auto=format&fit=crop&w=880&q=80"
        ),
        pills=[
            Pill(name="Vegetariano", color="green"),
            Pill(name="Sano", color="blue"),
            Pill(name="Rápido", color="yellow"),
        ],
    ),
    Recipe(
        id="2",
        name="Pasta Picante con Pollo",
        description=(
            "Una pasta cremosa y picante con pollo que satisfará tus antojos."
        ),
        image_url=(
            "https://www.zizzi.co.uk/propeller/uploads/2022/07"
            "/casareccia-pollo-piccante-e1667309010824.jpg"
        ),
        pills=[
            Pill(name="Pasta", color="green"),
            Pill(name="Picante", color="red"),
            Pill(name="Pollo", color="amber"),
        ],
    ),
    Recipe(
        id="3",
        name="Mousse de Chocolate con Aguacate",
        description=(
            "Un postre decadente y saludable hecho con aguacate cremoso y"
            " chocolate rico, perfecto para satisfacer tu antojo de dulce sin"
            " culpa."
        ),
        image_url=(
            "https://www.trops.es/wp-content/uploads/2020/03"
            "/mousse-aguacate-chocolate-1024x683.jpg"
        ),
        pills=[
            Pill(name="Postre", color="pink"),
            Pill(name="Sano", color="blue"),
            Pill(name="Vegano", color="green"),
        ],
    ),
    Recipe(
        id="4",
        name="Smoothie Verde Energizante",
        description=(
            "Un smoothie refrescante y rico en antioxidantes para comenzar tu día."
        ),
        image_url="https://www.hazteveg.com/img/recipes/full/201612/R03-65246.jpg",
        pills=[
            Pill(name="Desayuno", color="green"),
            Pill(name="Rápido", color="yellow"),
            Pill(name="Frutas", color="lime"),
        ],
    ),
)


class InMemoryRecipeRepository:
    """A fixed collection of recipes."""

    async def list_recipes(self) -> list[Recipe]:
        """Return the fixed collection."""
        return list(RECIPES)
