#!/bin/bash
# Runs uv against api/pyproject.toml and api/uv.lock; invoke through `make`.
# Not via run-in-container.sh: that builds the whole image, whose `uv sync
# --frozen` fails on exactly the stale lockfile this script exists to fix.
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

# Writable: the manifest and lockfile are written back here. --no-sync from the
# make targets keeps any environment out of this throwaway container.
exec docker run --rm --init \
	--volume "$REPO_ROOT/api:/workspace/api" \
	"$IMAGE" uv "$@"
