# Architecture

Read this before adding or moving any module in `api/src/muncher_api/`: a new
endpoint, entity, use case, storage or setting.

## Hexagonal, with one rule

**Dependencies point inwards.** The domain depends on nothing, the application
depends on the domain and the ports, and the adapters depend on whatever they
need. Nothing inside ever imports from outside: no `fastapi` or `sqlalchemy`
in `domain/`, `application/` or `ports/`. Pydantic is the one exception, for the
reason under "The layers".

```
muncher_api/
├── main.py         composition root: settings → adapters → use cases → routers
├── aws_lambda.py   Lambda entry point; wraps the app in main.py
├── config/         settings read from the environment
├── domain/         entities, as Pydantic models the API also serves
├── application/    use cases, written against the ports
├── ports/          interfaces the application needs, as Protocols
└── adapters/
    ├── http/       driving: FastAPI routers
    └── persistence/
        ├── memory/ driven: data held in the process
        └── sql/    driven: PostgreSQL through SQLAlchemy and psycopg
```

## The layers

- **`domain/`: Pydantic models inheriting from `Model` in `domain/model.py`**,
  which the routers return as they are. This is a deliberate shortcut: a
  separate set of API models would mirror the entities field for field, so the
  entities are the API's contract, camelCase serialisation included. It costs
  two things, and both are accepted: the domain depends on Pydantic, and
  changing an entity changes the OpenAPI schema and the front-end's generated
  types, so treat an entity change as an API change.
- **`application/`: one service class per aggregate**, such as `RecipeService`.
  It receives its ports in `__init__` and holds the logic a use case needs. A
  method that only forwards to a repository is fine; logic gets added there,
  never in a router or an adapter.
- **`ports/`: `Protocol`s, with no implementation**, grouped by what they are
  for (`ports/persistence/`). **Shape them after what the application asks**:
  `list_recipes`, and later queries like recipes by ingredient. Do not use a
  generic CRUD interface; every adapter would have to implement operations
  nobody calls.
- **`adapters/http/`: the driving adapter.** Routers call the services and
  return entities. A model of its own belongs here only when the HTTP shape
  really differs from an entity: a request body without the `id`, or a
  response that hides internal fields or adds derived ones. Such a model still
  inherits from `Model`.
- **`adapters/persistence/<technology>/`: the driven adapters**, one directory
  per kind of storage. An adapter satisfies its port structurally, with no
  inheritance. Code shared by every repository of one technology, such as a
  generic base for SQL CRUD, lives inside that technology's directory. It is
  never a port.
- **`config/`**: see [configuration.md](configuration.md).

## Wiring

**`main.py` is the only module that names a concrete adapter.** It reads the
settings, builds the adapters, passes them to the services, and passes the
services to the routers. Swapping a storage is a change there and nowhere else.

**Routers are built by factories that receive their service**:
`create_recipes_router(recipe_service)`. The endpoints are closures over it.
That keeps the types exact all the way through. Reading the service from
`app.state` or `request.state` would be untyped, and overriding a placeholder
`Depends` is a testing mechanism, not a wiring one.

Module-level wiring in `main.py` runs on import, which in Lambda is the init
phase. Anything that needs the event loop, like checking or closing the
database connection, goes in the lifespan instead.

## Adding a feature

1. The entity in `domain/`, which is also what the endpoints return.
2. The port in `ports/`, with only the methods the use case needs.
3. The use case in `application/`.
4. The adapter that implements the port, under `adapters/persistence/`.
5. The router in `adapters/http/`, plus a request or response model only if
   the HTTP shape differs from the entity.
6. The wiring in `main.py`.

## Where it stands

The recipes are served by `adapters/persistence/memory/`, a fixed collection,
because no table exists yet. `adapters/persistence/sql/` holds only the engine.
Its first repository arrives with the first table, along with the session
handling and the generic CRUD base it will share. At that point this section
is updated, and the in-memory adapter goes once nothing needs it.
