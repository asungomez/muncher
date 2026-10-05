"""The settings of the whole API, gathered from every group.

Each group is a `BaseSettings` model with its own prefix, read on its own
rather than nested in a parent model: nesting would rename the variables after
the parent, `DATABASE__HOST` instead of `DATABASE_HOST`. Whether a group is
required or optional is decided here, in `read_settings`, and nowhere else.
"""

from dataclasses import dataclass

from pydantic import ValidationError
from pydantic_settings import BaseSettings

from muncher_api.config.database import DatabaseSettings


@dataclass(frozen=True, kw_only=True)
class Settings:
    """Every setting the API reads from its environment."""

    # Optional until the cloud environments have a database, in Sprint 7.
    database: DatabaseSettings | None


class MissingSettingsError(Exception):
    """Environment variables that a group of settings requires are missing."""

    def __init__(self, missing_variables: list[str]) -> None:
        """Name the variables that are missing."""
        super().__init__(
            f"Set the missing environment variables: {', '.join(missing_variables)}."
        )


def read_settings() -> Settings:
    """Read every group of settings from the environment.

    Raises:
        MissingSettingsError: A required group, or an optional one that is
            partially set, lacks some of its variables.
    """
    return Settings(database=read_optional_settings(DatabaseSettings))


def read_required_settings[GroupT: BaseSettings](group: type[GroupT]) -> GroupT:
    """Read a group that every environment must set in full.

    Raises:
        MissingSettingsError: Any of its variables is missing.
    """
    try:
        return group()
    except ValidationError as error:
        missing_variables = list_missing_variables(group, error)
        if missing_variables:
            raise MissingSettingsError(missing_variables) from error
        raise


def read_optional_settings[GroupT: BaseSettings](
    group: type[GroupT],
) -> GroupT | None:
    """Read a group that an environment may leave out, as long as it is entirely.

    Returns:
        The settings, or None when none of the group's variables is set.

    Raises:
        MissingSettingsError: Some of its variables are set, but not all.
    """
    try:
        return group()
    except ValidationError as error:
        missing_variables = list_missing_variables(group, error)
        if len(missing_variables) == len(group.model_fields):
            return None
        if missing_variables:
            raise MissingSettingsError(missing_variables) from error
        raise


def list_missing_variables(
    group: type[BaseSettings], error: ValidationError
) -> list[str]:
    """Name the environment variables behind the fields the error reports missing."""
    prefix = group.model_config.get("env_prefix", "")
    return [
        f"{prefix}{field}".upper()
        for detail in error.errors()
        if detail["type"] == "missing"
        for field in detail["loc"]
    ]
