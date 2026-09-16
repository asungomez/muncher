# Docstrings

Read this before writing a docstring in `api/src/**`. The general rules — what
deserves a comment, and how short to keep it — are in
[coding/comments.md](../coding/comments.md); this is only the format.

## The Google convention

**Ruff enforces the `D` rules with `convention = "google"`**, configured in
`api/pyproject.toml`. That choice settles the details that pydocstyle otherwise
contradicts itself about, so the shape below is not a preference — the linter
fails without it.

What it requires:

- **A docstring on every module, class and public function.** No exceptions.
- **The summary starts on the line of the opening quotes**, is one sentence, is
  written in the imperative or as a statement of fact, and **ends in a full
  stop**.
- **A blank line between the summary and anything that follows**, and the
  closing quotes on their own line for a multi-line docstring.

```python
def list_recipes() -> list[Recipe]:
    """Devuelve la colección completa de recetas."""
    return RECIPES
```

## Do not restate the annotations

**The signature already says the types, and FastAPI already publishes them.** An
`Args:`/`Returns:` block that repeats what `-> list[Recipe]` says is duplication
that will drift.

Write an `Args:` entry only for a parameter with a constraint the annotation
cannot express — a unit, a range, a format, a relationship to another argument.
Write `Returns:` only where the value's meaning is not obvious from the function
name and its type. `Raises:` is worth it whenever a caller has a reason to catch
something.

## Docstrings that reach the schema

**Some docstrings are published**, which is the one thing that makes the API
different from the front-end:

- **A function decorated with a router method becomes the endpoint's description
  in the OpenAPI schema and on `/docs`.**
- **A Pydantic model's docstring becomes its schema description**, so it appears
  in the generated client and on the documentation page.

Write those knowing they will be read as API reference, not as an internal note:
say what the endpoint returns or what the model represents, from the point of
view of whoever is calling it.

**They are still English.** `/docs` is developer documentation, not the product —
being visible on a page does not make a docstring user-facing text. The Spanish
in this repository is the UI, the README and the memoria; see
[coding/language.md](../coding/language.md). The same goes for the `summary=`
strings passed to the routers and to `FastAPI(...)`, which land on the same page.

## Module docstrings

The module docstring is the one place where more than a couple of lines is
normal: it says what the module is for and records the decisions behind it, the
way `recipes.py` explains why the collection is fixed in code. Keep it to a
summary line, a blank line, and a short paragraph.
