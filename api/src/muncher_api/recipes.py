"""Recipes endpoints.

The collection is fixed in the code for now. It is the same data the front-end
currently hardcodes in its home page, and the models below describe the shape
that page already expects, so connecting the two is a matter of fetching this
endpoint instead of importing a constant.
"""

from typing import Literal

from fastapi import APIRouter
from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel

router = APIRouter(prefix="/recipes", tags=["recipes"])

# The colours a pill can be painted with, mirroring PILL_COLORS in
# front-end/src/components/Pill/utils.ts. Declared as a literal rather than as
# a plain string so that the OpenAPI schema enumerates them and the generated
# client types are as narrow as the handwritten ones.
PillColor = Literal[
    "green",
    "blue",
    "yellow",
    "orange",
    "red",
    "amber",
    "pink",
    "lime",
    "sky",
    "rose",
]


class Model(BaseModel):
    """Base of every model served by the API.

    Fields are named in snake_case here and serialised in camelCase, which is
    what the TypeScript client consumes. The mapping is declared once, so it
    applies to anything added later without being restated.
    """

    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)


class Pill(Model):
    """A tag classifying a recipe."""

    name: str
    color: PillColor


class Recipe(Model):
    """A cooking recipe."""

    id: str
    name: str
    description: str
    image_url: str
    pills: list[Pill]


RECIPES = [
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
]


@router.get("", summary="List the recipes")
def list_recipes() -> list[Recipe]:
    """Return the full collection of recipes."""
    return RECIPES
