# Types

Read this before writing TypeScript in `front-end/src/**`. The rules that apply
to every language — strictness, the forbidden escape hatches, preferring the
narrowest type — are in [coding/types.md](../coding/types.md); this is what is
specific to TypeScript here.

## The compiler settings are the floor

`front-end/tsconfig.app.json` sets `strict`, `noUnusedLocals`,
`noUnusedParameters`, `noFallthroughCasesInSwitch` and
`noUncheckedSideEffectImports`. **Those flags are not negotiable and a task never
relaxes one to make code compile.** `tsc -b` runs as part of `make
front-end-build`, so a type error fails the build, not just the editor.

## Derive types from values

**Where a set of values already exists at runtime, declare the values and take
the type from them.** `Pill/utils.ts` is the pattern:

```ts
export const PILL_COLORS = ["green", "blue", "yellow"] as const;
export type PillColor = (typeof PILL_COLORS)[number];
```

The alternative — a `const` array plus a hand-written union — is two things that
can disagree. `as const` is what makes the literal types survive.

Use the same reasoning for object shapes: `keyof typeof variantStyles` rather
than restating the variant names.

## Props

- **Props go in an `interface` named `<Component>Props`**, declared in the
  component's own file, above the component.
- **Extend the DOM props when the component wraps an element**, as `Button` does
  with `ButtonHTMLAttributes<HTMLButtonElement>`. It gives the caller `onClick`,
  `disabled`, `aria-*` and the rest without restating any of them.
- **Children are `ReactNode`**, imported as a type.
- **Optional means optional**, not "I did not want to pass it". A `?` is a
  promise that the component renders correctly without it, usually via a default
  in the destructuring: `variant = "primary"`.

## Imports

**`import type` for anything used only as a type.** `verbatimModuleSyntax` is on,
so a value import of a type is an error, and mixing the two in one statement
hides which is which:

```ts
import type { ButtonHTMLAttributes, ReactNode } from "react";
import { cn } from "../../utils/cn";
```

## Data crossing the network

**The API is the source of truth for its own shapes.** Types describing what an
endpoint returns live in `src/services/<resource>/types.ts` and must match the
models in `api/src/muncher_api/`, field for field, in camelCase — the API
serialises that way on purpose (see `Model` in `recipes.py`).

A response is **not** trusted into the type system for free: `fetch` returns
`any` in effect, so parse or validate at the boundary and keep the raw value out
of the rest of the app. Nothing downstream of a service module should have to
wonder whether a field is really there.
