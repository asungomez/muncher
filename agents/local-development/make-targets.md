# Make targets

## The principle

**Every task in this repository is invoked through a make target.** There are no
scripts to run by hand, no `cd` into a subdirectory first, and no `docker` or
`docker compose` command a developer is expected to remember.

```
make            # lists every target with its description
```

## Layout

- `Makefile` at the repository root defines shared variables and includes the
  fragments. It is not where targets live.
- `makefiles/*.mk` holds the targets, one fragment per subsystem:
  `local-env.mk` (the running application), `checks.mk` (verification),
  `memoria.mk` (the document).
- `scripts/` holds the implementation the targets call. Scripts are plumbing,
  not entry points — they live here rather than beside the code they act on, and
  the ones that run inside a container refuse to run outside it.

`RUN` is defined in the root `Makefile` as the container runner, so every
fragment can use `$(RUN) <command>` without repeating the path.

## Naming

Targets are named after the **subsystem** they act on, then the action:
`front-end-lint`, `front-end-build`, `memoria-build`, `memoria-watch`. The
subsystem comes first so that related targets sort together in `make help` and
a new subsystem is an obvious addition rather than a naming debate.

Targets that act on the whole repository or the whole stack take the bare verb:
`checks`, `up`, `down`, `logs`, `setup`.

## Adding a target

- Put it in the fragment for its subsystem, creating a new fragment if the
  subsystem is new — and add the `include` line to the root `Makefile`.
- Declare it `.PHONY` unless it genuinely produces the file it is named after.
- Give it a `## ` comment on the target line. That comment *is* the
  documentation: `make help` extracts it, so a target without one is invisible.
  Keep it to one line, in the imperative.
- Run whatever it does through `$(RUN)`, or through the compose stack. A recipe
  that invokes a host binary directly contradicts
  [containerized-development.md](containerized-development.md).
- Keep recipes to one or two lines. Anything longer belongs in `scripts/`, called
  from the recipe.

## Do not duplicate a definition

A target must not reimplement something that is already defined elsewhere. The
check targets are the example to follow: instead of calling ESLint and Prettier
themselves, they select a hook from `.pre-commit-config.yaml` by id
(`$(RUN) pre-commit run eslint --all-files`). The consequence is that
`make front-end-lint`, the commit-time hook and continuous integration cannot
disagree about what the check is, because there is only one definition of it.

Apply the same reasoning to anything new: if a tool is already configured
somewhere, the target selects from that configuration rather than restating it.

## Consequences for agents

- To run something, use its make target. Do not call `scripts/*.sh`,
  `docker compose` or a host binary directly when a target exists.
- If no target exists for a task a developer would plausibly want, adding one is
  part of the work — not a follow-up.
- When you change how a task runs, check whether `make help`, `README.md` and
  the CI workflow still describe it correctly. The workflow calls the same
  targets, so a renamed target breaks CI.
- Never document a bare script invocation for humans. `README.md` lists make
  targets.
