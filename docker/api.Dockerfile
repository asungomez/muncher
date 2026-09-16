# syntax=docker/dockerfile:1

# Image that runs the API development server. The sources are bind mounted at
# run time, never copied in, so uvicorn's reloader sees host edits.

# Its own stage so scripts/api-deps.sh can stop here, before the frozen install
# that fails when the lockfile is the thing needing an update.
FROM python:3.13-slim-bookworm AS uv

# Declared here so both images this file produces carry it; see ci.Dockerfile.
LABEL muncher.image=api

COPY --from=ghcr.io/astral-sh/uv:0.11.23 /uv /usr/local/bin/uv

# Outside /workspace, which the working tree is bind mounted over at run time.
ENV UV_PROJECT_ENVIRONMENT=/opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# The sources are imported from the bind mount, so no .pyc may land in it.
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/workspace/api/src

WORKDIR /workspace/api

FROM uv

# --frozen refuses to re-resolve, so a lockfile that no longer matches
# pyproject.toml fails the build instead of installing something else.
COPY api/pyproject.toml api/uv.lock ./
RUN uv sync --frozen --no-install-project

EXPOSE 9100

# --host 0.0.0.0 because the port is reached from the host, not from inside.
CMD ["uvicorn", "muncher_api.main:app", "--host", "0.0.0.0", "--port", "9100", "--reload"]
