# Configuration

Read this before adding a setting the API reads at run time, or touching how it
connects to the database.

## Settings come from the environment

**Anything that differs between environments is an environment variable, read
through a `pydantic-settings` model in `config/`.** Never a constant, never a
file in the repository. The same build then runs locally, in the tests and in
the cloud, and no credential is committed.

- **One module and one `BaseSettings` model per group**, with its own
  `env_prefix`: `config/database.py` holds `DatabaseSettings`, read from
  `DATABASE_*`.
- **`config/base.py` gathers them** into `Settings`, and `read_settings` is the
  only place that decides whether a group is required or optional, through
  `read_required_settings` or `read_optional_settings`. Both name the missing
  variables in the error, not Pydantic's field names.
- **Groups are read on their own, not nested** in a parent `BaseSettings`.
  Nesting would rename the variables (`DATABASE__HOST`).
- **Secrets are `SecretStr`**, so they do not leak into a log or a traceback.
- **Read once, in `main.py`**, which hands each group to the adapter that needs
  it. Nothing else reads the environment.
- **Locally the values are set on the service in `compose.yaml`.** Not with the
  `MUNCHER_` prefix: on the host that prefix configures the stack itself, and
  `MUNCHER_DATABASE_PORT` already means the port the database is published on.

## The database

SQLAlchemy 2, asynchronous, over psycopg 3, in `adapters/persistence/sql/`.
`main.py` builds the engine and the lifespan runs a `SELECT 1` through it before
the application starts serving.

**For now the database group is optional**, because the cloud environments
have no database until Sprint 7 and `main` deploys to dev on every push. A
partial set is still an error. Once every environment has a database, switch it
to `read_required_settings`, make the field non-optional and remove the
database-less branch from the lifespan.
