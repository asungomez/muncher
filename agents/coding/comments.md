# Comments

Read this before writing a comment or a docstring, in any language.

## Keep them to the minimum, and keep them short

**A comment is a cost.** It has to be read, and it has to be kept true — a
comment that drifts from the code is worse than no comment, because it is
believed. The goal is code that does not need one: see
[style.md](style.md).

- **Explain why, never what.** `# increment the counter` above `counter += 1`
  earns nothing. `# The API is 1-indexed` earns its place.
- **Two lines is the smell threshold.** A comment longer than that is usually a
  sign that the code under it needs a better name, a smaller function or an
  extracted helper. Fix the code first; if the explanation survives the fix, keep
  it.
- **Delete rather than update stale comments.** If you change code and the
  comment above it no longer holds, it is part of the change.
- **No commented-out code, and no `TODO`.** Git remembers the deleted version,
  and work that is worth doing belongs in an issue, not in a comment nobody
  reads again. `TODO`, `FIXME`, `XXX` and `HACK` are errors on both sides —
  Ruff's `FIX001`-`FIX004` in `api/`, `no-warning-comments` in `front-end/`.
  Commented-out code is caught by `ERA001`, which has no ESLint equivalent, so
  on the front-end that one rests on review.

## What does deserve a comment

- **Business logic that is genuinely involved** — a rule whose reasoning is not
  visible in the operations that implement it.
- **Workarounds that look wrong.** Anything a reader would be tempted to
  "clean up" and thereby break: a dependency's bug, an ordering that matters, a
  value that must match something elsewhere. Say what breaks if it is changed.
- **A decision with a discarded alternative.** Why this approach and not the
  obvious one.

## Configuration is not an exception

**Dockerfiles, `pyproject.toml`, `.pre-commit-config.yaml`, the `makefiles/`,
`compose.yaml`, the workflows and the `scripts/` headers follow the same rule as
the code.** They are the files that drift towards prose fastest, because every
decision feels worth recording — and they are where a stale comment does the most
damage, since nothing fails when one stops being true.

A config file often does have a genuine *why* that lives nowhere else. It still
gets one or two lines, not a paragraph:

```dockerfile
# Not "dev": uv installs that group on a bare `uv sync`, putting the toolchain
# in the runtime image.
```

If the explanation genuinely does not fit, it is documentation, not a comment.
It belongs in `README.md` or under `agents/`, where a reader can find it without
opening a Dockerfile.

## Docstrings

**Every function, class and module gets a docstring**, including small ones. A
docstring is not an exception to the brevity rule — it is what replaces the
running commentary the rule forbids, and one accurate line is a complete
docstring.

The expected format is language-specific:

- [front-end/docstrings.md](../front-end/docstrings.md) — TSDoc, for TypeScript.
- [api/docstrings.md](../api/docstrings.md) — the Google convention, for Python.
