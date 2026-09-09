# Muncher

Web application for end-to-end management of cooking recipes: create and import
recipes, inspect their nutritional values, plan menus and generate shopping
lists automatically. The repository also hosts *la memoria*, the LaTeX academic
report that documents the project.

Layout:

- `front-end/` — Vite + React client.
- `memoria/` — LaTeX sources of the project report; the PDF is built into
  `memoria/generated/`.
- `infra/` — CloudFormation templates. One stack per environment.
- `Makefile`, `makefiles/` — the entry point for every task in the repository.
- `docker/`, `compose.yaml` — the images and the local stack. Every task runs in
  a container; only git and Docker are needed on the host.
- `scripts/` — the implementation the make targets call.

Run `make` to list the available targets. See `README.md` for the human-facing
setup instructions.

## Index

Read the file that matches the task before starting work.

| Read | When |
| --- | --- |
| [agents/memoria/readme.md](agents/memoria/readme.md) | Working on the project's memory docs (the LaTeX memoria). |
| [agents/local-development/readme.md](agents/local-development/readme.md) | Working on local development: make targets, container images, git hooks, tool configuration and the READMEs that document them. |
| [agents/infra/readme.md](agents/infra/readme.md) | Working on the cloud infrastructure. |
