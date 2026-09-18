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
the type from them.** `RecipeCard/utils.ts` is the pattern:

```ts
export const RECIPE_CARD_VARIANTS = ["primary", "secondary"] as const;
export type RecipeCardVariant = (typeof RECIPE_CARD_VARIANTS)[number];
```

The alternative — a `const` array plus a hand-written union — is two things that
can disagree. `as const` is what makes the literal types survive.

Use the same reasoning for object shapes: `keyof typeof variantStyles` rather
than restating the variant names.

**Where the set belongs to the API, derive it from the API instead.**
`Pill/utils.ts` used to declare its own colour list; the colours are the API's
to decide, so it now takes the type from the generated schema and the runtime
list is gone:

```ts
export type PillColor = Pill["color"];
```

`Record<PillColor, string>` on the style map is what makes this pay: a colour
added to the API's `Literal` fails the build until it has styling.

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

**The API is the source of truth for its own shapes, and the types are
generated, not mirrored.** `make front-end-types` reads the schema FastAPI
derives from the endpoint annotations and writes
`src/services/api/schema.d.ts`; a pre-commit hook regenerates it, so a Pydantic
model cannot change without the front-end's types following in the same commit.
Nothing about a request is written twice — not the path, not its parameters, not
the response.

**So a service's `types.ts` names a generated type rather than restating it:**

```ts
export type Recipe = components["schemas"]["Recipe"];
```

Hand-writing that shape again, even correctly, is the thing this replaced. If
the field you need is missing, the fix is in `api/`.

**What the generation does not do is check at runtime.** The types describe what
the API promises; they are not evidence that this response kept the promise. So:

- **A request's failure is `unknown` and gets narrowed**, never assumed.
  `useApiQuery`'s error is deliberately `unknown` — a timeout and a broken
  connection are failures the schema does not describe — and
  `services/api/errors.ts` narrows it to the cases the interface handles.
- **Absence is handled where the data is read**, because a 200 with an
  unexpected body is a bug in the API rather than something to model everywhere.
  `useRecipes` returns `recipes` as possibly `undefined`, and the caller renders
  the empty case.
- **If an endpoint ever needs more than that** — a payload we do not control, or
  one where a wrong shape would corrupt something — validate it in that service
  module, so exactly one place knows and everything past it is typed. Raise it
  before adding a validation library.
