#!/bin/bash
# Runs uv against the API's manifests, api/pyproject.toml and api/uv.lock.
#
# Invoke it through `make api-install-dep DEP=<package>` or `make api-lock`. uv
# lives in the image built from docker/api.Dockerfile, not on the developer's
# machine.
#
#   ./scripts/api-deps.sh add 'httpx==0.28.1' --no-sync
#   ./scripts/api-deps.sh lock
#
# It does not go through scripts/run-in-container.sh, which always builds the
# whole image: the final stage installs the dependencies with `uv sync
# --frozen`, which fails when the lockfile no longer matches the manifest —
# exactly the situation these commands exist to fix. Building only the `uv`
# stage stops before that step.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

if ! command -v docker >/dev/null 2>&1; then
	echo "❌ docker not found. It is the only tool this project requires on your machine." >&2
	exit 1
fi

IMAGE=muncher-api-uv:local

docker build --quiet --target uv \
	-f docker/api.Dockerfile -t "$IMAGE" . >/dev/null

# api/ is mounted writable because the manifest and the lockfile are written
# here. Nothing else leaves the container: the make targets pass --no-sync, so
# no environment is created in this throwaway one. The environment the server
# runs in is built from the lockfile by docker/api.Dockerfile, which
# `make api-up` rebuilds.
exec docker run --rm --init \
	--volume "$REPO_ROOT/api:/workspace/api" \
	"$IMAGE" uv "$@"
