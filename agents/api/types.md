# Types

Read this before writing Python in `api/src/**`. The rules that apply to every
language — strictness, the forbidden escape hatches, preferring the narrowest
type — are in [coding/types.md](../coding/types.md); this is what is specific to
Python here.

## Annotate everything

**Every parameter, every return, every module-level constant whose type is not
obvious from its value.** A function with no annotations is invisible to the type
checker, which is worse than one with a wrong annotation: nothing reports it.

This is enforced, not merely asked for, by two tools with different jobs:

- **Ruff's `ANN` rules** fail on a missing annotation, and `ANN401` rejects `Any`.
  Ruff is what makes sure a signature is annotated at all.
- **ty** then checks that the annotations are true, with every one of its rules
  raised to error (`--error all`). That promotes 39 rules that ship as warnings
  or disabled, including `missing-type-argument` — a bare `list` is rejected,
  `list[Recipe]` is required — which is this document's "prefer the most specific
  type" made mechanical.

ty runs over the whole project rather than the changed files, because a type
error is introduced in one module and surfaces in another that imports it.

`api/pyproject.toml` requires Python 3.13, so use the modern spellings and
nothing else:

| Write | Not |
| --- | --- |
| `list[Recipe]`, `dict[str, int]` | `List[Recipe]`, `Dict[str, int]` |
| `Recipe \| None` | `Optional[Recipe]` |
| `str \| int` | `Union[str, int]` |

Ruff's `UP` rules rewrite the left column for you, so the right column will not
survive a commit.

## Types are the API

**This is the part that makes the back-end unusual: the annotations are not only
checked, they are published.** FastAPI derives the OpenAPI schema from them, and
that schema is what the front-end's types are written against. A loose
annotation here becomes a loose type on the other side of the network.

- **A fixed set of values is a `Literal`, never a `str`.** `PillColor` in
  `recipes.py` is the example: as a `Literal` it is enumerated in the schema, so
  the generated client is as narrow as a handwritten type. As a `str` it would
  document nothing.
- **A response model is a Pydantic model**, not a `dict`. `dict[str, Any]`
  publishes an empty schema and is doubly forbidden — see
  [coding/types.md](../coding/types.md).
- **Declare the return type on endpoints** and let FastAPI infer the response
  model from it, rather than passing `response_model=`. One declaration instead
  of two that can disagree.

## Models

**Every model inherits from `Model` in `recipes.py`**, which carries the
camelCase alias generator. Fields are `snake_case` in Python and serialise as
camelCase, so the TypeScript client consumes what it expects. A model that
inherits from `BaseModel` directly breaks that silently, in one endpoint only.

Prefer Pydantic's own constrained types to a bare primitive plus a validator when
the constraint is simple — the constraint then reaches the schema too.

## Narrowing

**`assert` is not narrowing** — it can be stripped at runtime, and it turns a
type problem into a crash. Narrow with `if x is None: return ...`, with
`isinstance`, or by structuring the code so the impossible case does not typecheck.

Where a value genuinely arrives untyped from outside the process, parse it into a
model at the boundary. Past that line everything is typed, and nothing downstream
has to re-check it.
