# Types

Read this before writing in a language that admits typing: TypeScript anywhere
in `front-end/`, and Python in `api/`.

## Typing is as strict as it comes

**Everything is annotated and nothing is exempt.** The type checker is not a
suggestion engine; code that does not satisfy it is not finished.

## The escape hatches are forbidden

There is no approved use of any of these:

| Forbidden | Language |
| --- | --- |
| `any`, `as any`, `Function`, `object` as a stand-in | TypeScript |
| `@ts-ignore`, `@ts-expect-error`, `@ts-nocheck` | TypeScript |
| `Any`, `cast()` used to silence rather than narrow | Python |
| `# type: ignore`, `# ty: ignore`, `# noqa` on a typing rule | Python |
| Loosening `strict` in `tsconfig`, or excluding a file from the checker | Both |

**A type error is information.** It means the code makes an assumption the types
do not support, and the fix is to make the assumption true or to stop making it —
not to assert it away. `unknown` plus a narrowing check is the answer to "I do
not know what this is"; `any` never is.

In `api/` this is enforced rather than asked for: a `no-type-suppressions` hook
rejects `# ty: ignore` and `# type: ignore` in any form, targeted ones included.

If a third-party package is genuinely untyped, the fix is a typed wrapper at the
boundary, so exactly one small module knows about the gap and everything past it
is typed. Raise it before writing one.

## Prefer the most specific type available

**Never widen past what you actually know.** The type should admit the values
that are legal and reject the rest.

- `PillColor` over `string`, `list[Recipe]` over `list[object]`,
  `Literal["draft", "published"]` over `str`.
- **Derive, do not restate.** The API declares the pill colours once, as a
  `Literal`, which narrows its OpenAPI schema; the front-end takes `PillColor`
  from the types generated off that schema. One declaration, and nothing to keep
  in step by hand. Where a set has no owner outside the front-end, the same
  reasoning applies locally: declare the values `as const` and take the type
  from them, as `RECIPE_CARD_VARIANTS` does.
- **A union of known cases beats a catch-all**, and it makes the checker prove
  every case is handled.
- **Make illegal states unrepresentable** where the language allows it: a
  discriminated union rather than four optional fields where only certain
  combinations are valid.
- Optionality is a decision. `Recipe | None` says a caller must handle absence;
  do not add `| None` to avoid initialising something.

## Language-specific rules

- [front-end/types.md](../front-end/types.md) — TypeScript.
- [api/types.md](../api/types.md) — Python.
