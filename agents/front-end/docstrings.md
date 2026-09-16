# Docstrings

Read this before writing a docstring in `front-end/src/**`. The general rules —
what deserves a comment, and how short to keep it — are in
[coding/comments.md](../coding/comments.md); this is only the format.

## ESLint enforces this

`eslint-plugin-jsdoc` is configured in `front-end/eslint.config.js`, so the
shape below is not a preference — the hook fails without it. What it checks:

| Rule | Effect |
| --- | --- |
| `require-jsdoc` | Every function declaration, and every arrow bound to a name, carries a block. |
| `require-description` | The block says something; an empty one does not count. |
| `no-types` | No `{string}` in a tag — TypeScript supplies the types. |
| `require-param-description`, `require-hyphen-before-param-description` | A `@param` that is present is written `@param name - Description.` |
| `check-tag-names`, `check-alignment`, `tag-lines` | Tags are real and the block is laid out consistently. |

The plugin's own recommended preset is deliberately **not** extended: it demands
`@param` and `@returns` on everything, which is exactly what the next section
rules out.

## TSDoc, above the declaration

**Use a `/** ... */` block immediately above the exported declaration.** Not `//`
lines, and not a block inside the function body.

```tsx
/** A coloured tag classifying a recipe. */
function Pill({ name, color }: PillProps) {
```

One sentence, ending in a full stop, on a single line where it fits. Every
declaration under `front-end/src/**` already has one; a new one is not finished
without it.

## Do not restate the types

**TypeScript already says what the parameters are and what comes back.** A
docstring that lists them again is duplication that will drift.

- **No `@param` for a parameter whose name and type already say it.** Use one
  only where a value has a constraint the type cannot express — a unit, a range,
  an expected format.
- **No `@returns`** unless the return type is a bare `string`, `number` or
  `boolean` whose meaning is not obvious from the function name.
- **No `@type`, `@class`, `@function`** — TypeScript supplies all of it.

```ts
/**
 * Merges Tailwind classes, with later classes overriding earlier ones.
 *
 * @param inputs - Class values; falsy entries are dropped.
 */
```

## What to write for each kind of declaration

- **Components** — what it renders and when it is used, from the caller's point
  of view: *"A coloured tag classifying a recipe."*, not *"Renders a span."*
- **Hooks** — what the returned value represents and what triggers a re-render.
- **Utilities** — what the function computes. Note anything surprising about
  edge cases: empty input, duplicates, ordering.
- **Types and interfaces** — a line only where the name does not carry it.
  `interface ButtonProps` needs nothing; a type encoding a business rule does.
- **Modules** — no file-level block. The directory layout says where things
  live, see [directory-structure.md](directory-structure.md).

## Language

**Docstrings are written in English**, like the rest of the code — the opposite
of user-facing strings, which are Spanish and live in the locale files. See
[coding/language.md](../coding/language.md) and [i18n.md](i18n.md).
