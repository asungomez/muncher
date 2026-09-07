# Running checks

## The principle

**Do not run linters, formatters or tests automatically after making changes.**

Make the changes as well as you can and stop there. Leave running the checks to
the developer.

## Why

- The pre-commit hook already runs them, so an agent running them too is
  duplicated work.
- Each run costs time and tokens that the task itself does not need.
- The developer is the one who decides when the work is ready to be checked.

## What this means in practice

- After editing code, report what you changed and stop. Do not follow up with a
  lint, format, type-check, build or test run to "verify" it.
- Do not add such a run as a final step in a plan, and do not treat a task as
  unfinished because nothing was executed.
- Write the change as if it will be checked: match the project's formatting and
  conventions on the first attempt, since no automatic pass will tidy it up for
  you.
- If you are genuinely unsure whether a change is correct, say so in your report
  and explain what should be checked, rather than running the check yourself.

## When to run them anyway

- **The developer asks.** They may enable automatic checks for a session — for
  example "run the tests after each change" or "check as you go". That
  instruction holds for that session and overrides this document.
- **The developer asks for a one-off run.** "Run the linter now" is a task in
  itself; do it.
- **The task is the checks themselves.** Diagnosing a failing check, changing
  the tooling's configuration, or fixing something CI reported all require
  running it to know where you stand.
- **The task is the tooling.** Changing an image, a make target, the compose
  stack or the hook configuration cannot be verified by reading it. Run it.

Outside those cases, no automatic runs.

## When you do run them

Use the make targets, never the underlying tool
(see [make-targets.md](make-targets.md)):

| Command | Runs |
| --- | --- |
| `make checks` | every check, over the whole repository |
| `make checks-staged` | every check, over the staged files only |
| `make front-end-lint` | ESLint |
| `make front-end-format` | Prettier |
| `make memoria-lint` | latexindent |
| `make front-end-build` | the front-end build |
| `make memoria-build` | the memoria build |

Note that the fixing checks rewrite files in the working tree. After a run,
report what was modified rather than leaving the developer to discover it.
