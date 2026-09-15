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
│   │   └── Routes.tsx       # Router definition and the shared layout
│   ├── i18n/
│   │   ├── I18nProvider/    # Provider and its context
│   │   └── locales/         # One JSON file per language
│   ├── services/            # Per-domain data access and its types
│   │   └── recipes/
│   │       └── types.ts
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
| Types or calls for a data domain | `src/services/<domain>/` |
| A helper used across components | `src/utils/<name>.ts` |
| A translated string | `src/i18n/locales/<language>.json` |
| An image, icon or manifest | `front-end/public/` |

## The conventions this follows

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
- **The shared layout belongs to the router.** `routes/Routes.tsx` defines the
  `Layout` that wraps every page with the navbar and footer, so a new page gets
  those by being routed, not by rendering them itself.
- **Types describing data live in `services/`**, not next to the component that
  displays them: `services/recipes/types.ts` defines `Recipe`, which the pages
  and components import.
- **Assets in `public/` are referenced by absolute path** (`/page_background.png`)
  and are not imported as modules.
