# Components

Read this before adding a component, or before adding anything to a file that
already has one. Where the file goes is in
[directory-structure.md](directory-structure.md); how it is styled is in
[styles.md](styles.md). This is the rule about what a file may hold.

## One component per file

**A file declares exactly one component.** Not a main one plus a small helper
that happens to return JSX, and not two siblings that are only ever used
together.

```
components/RecipesSection/RecipesSection.tsx   # RecipesSection, and nothing else
routes/Layout.tsx                              # Layout, and nothing else
```

## Why

- **The file is the component's address.** `components/Pill/Pill.tsx` is where
  `Pill` is, without searching. A component tucked inside another file is one
  nobody finds — so when it is needed elsewhere it gets written again instead of
  imported.
- **It keeps a file honest about its size.** Two components in one file is how a
  200-line file starts, and the second one is always the one that never gets a
  test or a second look in review.
- **Fast Refresh depends on it.** `eslint-plugin-react-refresh` is configured in
  `eslint.config.js`: a module that exports more than one component loses hot
  reloading, and the rule is an error rather than a style preference.

## What counts as a component

**Anything that returns JSX and is used as `<Something />`.** Its size is not
the test, and neither is how many places use it: a component rendered in exactly
one parent still gets its own file. "It is only used here" is the argument that
produced the file you are about to add to.

What is *not* a component, and stays where it is:

- **A callback passed inline** to `map`, an event handler, or a render prop.
- **A helper that computes a value** rather than rendering one — a class-name
  lookup, a formatter. Those belong in the component's `utils.ts` when only it
  needs them, or in `src/utils/` when they have no owner.

## What else the file may hold

Only what belongs to that one component: its `<Component>Props` interface, the
style maps and constants it alone reads, and its docstring. Anything a second
file needs to import moves out — to `utils.ts` beside it, or to `services/` if
it describes data. See [directory-structure.md](directory-structure.md).
