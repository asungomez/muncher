# Language

Read this before writing any text, in code or around it. The project is
bilingual on purpose, and which language a string is written in depends on who
reads it.

## The rule

**Code is English. What a user reads is Spanish.**

| English | Spanish |
| --- | --- |
| Identifiers: variables, functions, types, components, files | UI strings, in `front-end/src/i18n/locales/` |
| Comments | `README.md` and the documents under `docs/` |
| Docstrings | The memoria, `memoria/src/**` |
| Commit messages, branch names | Anything else a person sees while using the product |
| These `agents/` documents | |

The line is **who the reader is**, not where the string sits. A Spanish
docstring on an English function is the common mistake: whoever reads it is
maintaining the code, so it is English like the code around it.

## Why this split

English identifiers keep the code consistent with its own dependencies — React,
FastAPI, Pydantic and the standard libraries are all English, and a codebase that
mixes `receta` with `Recipe` ends up with two names for one concept. The memoria
and the product are for Spanish readers, and the memoria is explicitly written in
Spanish (Spain); see [memoria/tone.md](../memoria/tone.md).

## Do not half-translate

**Never write a Spanish word in an English identifier, or the reverse.** No
`getReceta`, no `listaDeRecipes`, no `PLATOS_DESTACADOS`. The same concept keeps
one name across both languages of the stack: a recipe is `Recipe` in `api/` and
`Recipe` in `front-end/`.

User-facing Spanish never gets hard-coded next to the code either. It lives in
the locale files and reaches the markup through `t()`; see
[front-end/i18n.md](../front-end/i18n.md).

## The edge case worth knowing

**`/docs` is developer documentation, not the product.** FastAPI publishes an
endpoint's docstring as its description and a Pydantic model's docstring as its
schema description, which makes those docstrings visible on a page — but the page
is read by whoever consumes the API, not by someone cooking dinner. They are
docstrings, so they are English.

See [api/docstrings.md](../api/docstrings.md).
