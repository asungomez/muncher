# syntax=docker/dockerfile:1

# Image that runs the API development server.
#
# It is a snapshot of the runtime and the dependencies only. The source code is
# never copied in: it is bind mounted from the host at run time, so editing a
# file on the host is picked up by uvicorn's reloader immediately.
#
# Build from the repository root:
#   docker build -f docker/api.Dockerfile -t muncher-api:local .

# The dependency resolver, on top of the runtime. It is its own stage so that
# scripts/api-deps.sh can stop the build here — before the frozen install
# below, which is precisely what fails when the lockfile is the thing that
# needs updating.
FROM python:3.13-slim-bookworm AS uv

# Lets scripts/run-in-container.sh recognise — and discard — the untagged images
# left behind by its own rebuilds. Declared in this stage because the final one
# inherits it, so both images this file produces carry it.
LABEL muncher.image=api

COPY --from=ghcr.io/astral-sh/uv:0.11.23 /uv /usr/local/bin/uv

# The virtual environment lives outside /workspace, which the working tree is
# bind mounted over at run time: inside it, the mount would hide it.
ENV UV_PROJECT_ENVIRONMENT=/opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# The sources are imported from the bind mount, not installed, so nothing must
# leave .pyc files behind in the working tree.
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/workspace/api/src

WORKDIR /workspace/api

FROM uv

# Dependencies are installed at build time from the manifests alone, so this
# layer is rebuilt only when they change — not on every source edit. --frozen
# installs exactly what uv.lock pins and refuses to re-resolve, so a lockfile
# that no longer matches pyproject.toml fails the build instead of quietly
# producing a different environment than the one committed.
COPY api/pyproject.toml api/uv.lock ./
RUN uv sync --frozen --no-install-project

# Uvicorn must listen on every interface: the port is reached from the host, not
# from inside the container.
EXPOSE 9100

# --reload restarts the server whenever a source file changes. It watches the
# working directory, which is the bind mounted api/.
CMD ["uvicorn", "muncher_api.main:app", "--host", "0.0.0.0", "--port", "9100", "--reload"]
