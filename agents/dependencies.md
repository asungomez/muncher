# Dependencies

Read this before adding, upgrading or choosing a dependency, in any subsystem:
the front-end's `package.json`, the API's `pyproject.toml`, the tooling the
check image carries, or anything a `Dockerfile` pulls in.

A dependency is a decision the project cannot easily take back: it ships in the
bundle, it sets a floor on the versions of everything else, and somebody has to
keep it current. These three rules are what makes that decision reviewable.

## Always take the latest stable version

**A new dependency is declared at the newest version its publisher marks
stable**, and the declared range is what actually gets installed.

- **Stable means the release channel, not the number.** `npm` says
  `dist-tags.latest`; PyPI says the newest non-pre-release. A `next`, `beta`,
  `rc`, `alpha` or `dev` release is not stable, and neither is a version that is
  published but deliberately not tagged `latest` — its publisher is holding it
  back for a reason.
- **The range names that version**: `"swr": "^2.5.1"`, not `"^2.3.6"` because
  that is what an old tutorial said. A range that trails the installed version
  tells the next reader something untrue about what was chosen.
- **Starting old is a cost with no benefit.** The upgrade is owed either way,
  and paying it later means paying it across more of our own code.

## Only take what is actively maintained

**Check the project before depending on it**, and say what you found when you
propose it.

- **A release in the last few months, and open issues that get answered.** An
  archived repository, or a last release two years old against a stack that has
  moved, is a dependency that will have to be replaced.
- **Prefer the one the ecosystem already converged on.** Download volume is
  weak evidence on its own, but a package the rest of the toolchain builds on
  is one whose breakages get found by somebody else first.
- **A thin single-maintainer package can still be the right answer** — say so
  explicitly when it is, along with what the exit looks like if it stops being
  maintained.

## Never take an untyped dependency

**A dependency must ship its own types**: TypeScript declarations in the
package, or `py.typed` and real annotations for Python.

- **`@types/*` from DefinitelyTyped counts**, since that is how much of the
  React ecosystem still distributes its types, but a package that types itself
  is preferable — a separate types package is a second thing that can drift.
- **A package with no types anywhere does not get added.** It would either
  spread `any` through the code, which
  [coding/types.md](coding/types.md) forbids outright, or oblige us to maintain
  a typed wrapper around somebody else's API. If a dependency is genuinely
  unavoidable and genuinely untyped, that is a conversation with the developer
  before any code is written, not a decision to make while writing it.

## How to add one

**Through the make target, never by editing the manifest.** The target resolves
the version and updates the lockfile in the same step; a hand-edited manifest
disagrees with its lockfile, and every containerized task fails on the frozen
install until the two are reconciled.

| Subsystem | Command |
| --- | --- |
| Front-end | `make front-end-install-dep DEP=package@version` (`DEV=1` for a development dependency) |
| API | `make api-install-dep DEP=package==version` (`GROUP=group` for tooling) |

Removal is `make front-end-remove-dep DEP=package` and
`make api-remove-dep DEP=package`. See
[local-development/make-targets.md](local-development/make-targets.md).

**If a manifest has already been hand-edited, re-resolve the lockfile before
anything else.** `make front-end-lock` and `make api-lock` exist for exactly
that, and each runs the one image stage that stops before the frozen install —
otherwise the toolchain needed to fix the lockfile is itself unbuildable.

## What to say when proposing one

Name the version you are taking and why that package: what it is for, when it
was last released, that it is typed, and what the alternative you rejected was.
Four lines. A dependency that arrives in a diff with no argument behind it is a
dependency nobody can evaluate later.
