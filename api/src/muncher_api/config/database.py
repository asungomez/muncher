"""The database's settings."""

from pydantic import SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class DatabaseSettings(BaseSettings):
    """The access data of the database, read from DATABASE_* variables."""

    model_config = SettingsConfigDict(env_prefix="DATABASE_")

    host: str
    port: int
    name: str
    user: str
    password: SecretStr
