# Containerized development

## The principle

**Never force the developer to install tools on their own machine.**

Every stage of development happens inside a container: running the local stack,
running code checks, running tests, building the memoria, generating anything.
The only things a developer may be required to have are git and a container
runtime. Nothing else — no Node.js, no Yarn, no Python, no LaTeX distribution,
no Perl modules — is ever a prerequisite for working on this project.

## Why

- **Repeatability between machines.** Two developers on different operating
  systems, with different toolchain versions installed, must get identical
  results from the same command.
- **Repeatability between local and CI.** A check that passes locally must pass
  in CI, and vice versa. The way to guarantee that is for both to execute the
  *same image*, not two independent installations that happen to be configured
  alike.
- **No stale local state.** Nothing should break because a developer has not run
  an install command since the last dependency update, or because their language
  runtime drifted from the version the project expects. The container defines
  the environment; the developer does not maintain it.
- **Disposability.** A broken environment is fixed by rebuilding an image, not by
  debugging one person's machine.

## What this means in practice

- Each toolchain in the monorepo gets an image that contains its dependencies
  and the exact runtime versions the project targets. Images live in `docker/`,
  one per toolchain.
- Every developer-facing task is invoked through a make target that runs it in a
  container — see [make-targets.md](make-targets.md). A task that can only be run
  by first installing something locally is not finished.
- Dependency installation happens in the image build, not as a step the
  developer remembers to run.
- CI runs the same make targets a developer runs, which build and use the same
  images. CI must not install toolchains of its own or pin versions
  independently — if CI and the local environment can drift apart, the setup is
  wrong.
- Source code is mounted into the container rather than copied into it for
  development, so editing on the host takes effect immediately and generated
  output lands in the working tree where the developer expects it.
- The pre-commit hook runs its checks inside the container too. The hook itself
  is the only shell that runs on the host, and it must do nothing more than
  delegate.
- Tool versions are pinned in the image definitions. An image that resolves
  "latest" at build time reintroduces exactly the drift this principle exists to
  remove.

## Consequences for agents

- When adding a tool, add it to an image — never to a list of things the
  developer must install.
- When a task requires running something, run it through its make target rather
  than invoking a host binary, a script or `docker` directly.
- When you find setup instructions that ask the developer to install a tool,
  treat them as a defect to report, not a pattern to follow.
- Documentation for humans lists make targets. It does not document a
  host-install fallback, because there isn't one.
