"""The base of every entity in the domain."""

from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel


class Model(BaseModel):
    """Base of every entity, which the API also serves as is.

    Fields are named in snake_case here and serialised in camelCase, which is
    what the TypeScript client consumes. The mapping is declared once, so it
    applies to anything added later without being restated.
    """

    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)
