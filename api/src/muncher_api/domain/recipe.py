"""Recipes, as the application understands them and the API serves them."""

from typing import Literal

from muncher_api.domain.model import Model

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
