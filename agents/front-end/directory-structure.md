# Directory structure

Where things live in `front-end/`, and where a new file belongs.

This describes the structure as it stands. **When the structure changes, this
file changes with it** — a new top-level directory under `src/`, or a new
convention for an existing one, is not finished until it is recorded here.

## The tree

```
front-end/
├── public/                  # Served verbatim, referenced by absolute path
├── src/
│   ├── main.tsx             # Entry point: mounts <App> into #root
│   ├── App.tsx              # Composes the providers around the router
│   ├── index.css            # Tailwind import and global styles
│   ├── vite-env.d.ts        # Vite's ambient types
│   ├── components/          # Reusable presentational components
│   │   └── Button/
│   │       └── Button.tsx
│   ├── pages/               # One directory per route target
│   │   └── Home/
│   │       └── Home.tsx
│   ├── routes/
│   │   ├── Routes.tsx       # Router definition
│   │   └── Layout.tsx       # The shell every page renders inside
│   ├── i18n/
│   │   ├── I18nProvider/    # Provider and its context
│   │   └── locales/         # One JSON file per language
│   ├── services/            # Data access: the API boundary and its domains
│   │   ├── api/             # Shared across domains, not one of them
│   │   │   ├── schema.d.ts  # Generated from the API; never edited by hand
│   │   │   ├── client.ts    # The typed client, its timeout and SWR defaults
│   │   │   └── errors.ts    # Classifies what a request threw
│   │   └── recipes/
│   │       ├── types.ts     # Recipe and Pill, taken from the schema
│   │       └── useRecipes.ts
│   └── utils/               # Helpers not tied to any component
│       └── cn.ts
```

## Where a new file goes

| What you are adding | Where |
| --- | --- |
| A reusable component | `src/components/<Name>/<Name>.tsx` |
| Helpers or types used by one component only | `src/components/<Name>/utils.ts` |
| A screen reached by a route | `src/pages/<Name>/<Name>.tsx` |
| A new route | An entry in `src/routes/Routes.tsx`, pointing at a page |
| Types for a data domain | `src/services/<domain>/types.ts`, taken from the schema |
| A hook that reads an endpoint | `src/services/<domain>/use<Name>.ts` |
| Anything about the API itself, not one domain | `src/services/api/` |
| A helper used across components | `src/utils/<name>.ts` |
| A translated string | `src/i18n/locales/<language>.json` |
| An image, icon or manifest | `front-end/public/` |

## The conventions this follows

- **One component per file**, with no exception — see
  [components.md](components.md).
- **One directory per component, named after the component**, containing a file
  of the same name: `components/Pill/Pill.tsx`. Directories are `PascalCase`
  when they hold a component, lowercase otherwise (`utils/`, `services/`,
  `i18n/locales/`).
- **`utils.ts` beside a component holds what only that component needs** — the
  colour list and `PillColor` type live in `components/Pill/utils.ts`, not in
  `src/utils/`. `src/utils/` is for helpers with no owner, such as `cn.ts`.
- **Components are exported as default**, and imported by relative path
  (`../../components/Button/Button`). There are no path aliases and no barrel
  `index.ts` files; do not introduce either without deciding it as a convention
  and recording it here.
- **Pages are components too** — they differ only in being the thing a route
  renders, so they live in `pages/` rather than `components/`.
- **A context lives beside its provider**, in a separate `context.ts`, and
  exports both the context and the hook that reads it — as
  `i18n/I18nProvider/context.ts` exports `I18nContext` and `useI18n`. The
  provider imports the context; consumers import the hook.
- **The shared layout belongs to the router.** `routes/Layout.tsx` is the shell
  that wraps every page with the navbar and footer, and `routes/Routes.tsx`
  routes pages inside it — so a new page gets those by being routed, not by
  rendering them itself. It lives in `routes/` rather than `components/`
  because the router is its only caller; `routes/` is the one place a component
  sits directly in a lowercase directory rather than in one named after it.
- **Types describing data live in `services/`**, not next to the component that
  displays them: `services/recipes/types.ts` defines `Recipe`, which the pages
  and components import. It no longer spells the shape out — it names it in
  `services/api/schema.d.ts`, which is generated from the API.
- **`services/api/` is the boundary itself, not a domain.** The generated
  schema, the client built on it and the error classification live there because
  every domain needs them; `services/<domain>/` holds what is specific to one
  resource. `schema.d.ts` is the one file in `src/` nobody edits: it is written
  by `make front-end-types` and excluded from ESLint, which would otherwise
  rewrite its annotations.
- **A hook is named after what it returns**, in a file of the same name:
  `services/recipes/useRecipes.ts`. Data hooks live with the domain's types
  rather than in the page that happens to call them first.
- **Assets in `public/` are referenced by absolute path** (`/page_background.png`)
  and are not imported as modules.
