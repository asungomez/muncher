#!/bin/bash
# Re-resolves front-end/yarn.lock from front-end/package.json; invoke through
# `make front-end-lock`. Not via run-in-container.sh: that builds the whole
# image, whose `yarn install --immutable` fails on exactly the stale lockfile
# this script exists to fix.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

if ! command -v docker >/dev/null 2>&1; then
	echo "❌ docker not found. It is the only tool this project requires on your machine." >&2
	exit 1
fi

IMAGE=muncher-front-end-yarn:local

docker build --quiet --target yarn \
	-f docker/front-end.Dockerfile -t "$IMAGE" . >/dev/null

# Writable: the lockfile is written back here. update-lockfile resolves the
# manifest without linking anything, so the mount gets no node_modules.
exec docker run --rm --init \
	--volume "$REPO_ROOT/front-end:/workspace/front-end" \
	"$IMAGE" yarn install --mode=update-lockfile
