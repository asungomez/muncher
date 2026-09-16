# Style

Read this before writing or changing any code, in any language.

## Write code that explains itself

**The code is the documentation.** A reader who knows the language should
understand what a function does without a comment telling them, and without
jumping to its definition to find out what a variable holds.

This is the rule the others serve: [comments.md](comments.md) is short precisely
because self-documenting code leaves little for a comment to add.

## Name things properly

**A name says what the thing is, in full words.** `recipes` over `data`,
`selectedPillColor` over `c`, `hasPendingChanges` over `flag`.

- **No abbreviations a newcomer would have to decode.** `index` over `idx`,
  `response` over `res`, `error` over `err`. The established ones stay: `id`,
  `url`, `api`, `props`, and the `i`/`j` of a numeric loop.
- **Booleans read as a claim**: `isLoading`, `hasImage`, `canSubmit` — something
  that is true or false, not `loading` or `image`.
- **Functions read as an action**: `listRecipes`, `buildShoppingList`,
  `toCamelCase`. A function named after a noun should probably be a value.
- **Follow the language's casing**, which the linters enforce: `camelCase` in
  TypeScript, `snake_case` in Python, `SCREAMING_SNAKE_CASE` for constants in
  both.
- **The same concept keeps the same name everywhere**, across languages
  included. A recipe is a `Recipe` in `api/` and a `Recipe` in `front-end/`, not
  a `Dish` on one side.

If a good name is hard to find, the unit usually does more than one thing. Split
it and name the pieces.

## Do not repeat yourself

**Anything true in two places should be declared in one.** A value, a type, a
rule, a piece of behaviour.

The repository already works this way and the pattern is worth copying: Tailwind
colours exist once in the `@theme` block, the checks exist once in
`.pre-commit-config.yaml` and the make targets select from it, the API's
dependency versions exist once in `uv.lock`.

Extract at the second occurrence, not the third — but extract a **shared
meaning**, not a shared shape. Two functions that happen to have the same five
lines for unrelated reasons are not duplication, and merging them couples things
that should be free to change apart. Ask whether a change to one would always
have to be made to the other; if not, leave them alone.

## Challenge what is already there

**Finding a better solution to a problem the repository already solved is a
result, not a distraction.** Say so, and propose the change.

- If the existing code is wrong, or has been superseded by something the
  language or a dependency now offers, the fix is to change it — not to write
  new code that imitates it for consistency.
- Consistency is worth a lot, so an improvement applied to one call site and not
  the other four is worse than either option. Change them together, or leave it
  and raise it.
- A convention recorded in `agents/` is a decision, not a law. Where a task would
  depart from one, that is a convention change: decide it deliberately with the
  developer and update the document, rather than leaving code and document to
  disagree.

What this is not: rewriting working code because it would read better a
different way. Leave the code you did not come to change.
