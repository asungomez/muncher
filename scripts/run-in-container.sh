#!/bin/bash
# Runs a command inside the CI image.
#
# This is the single place where the host touches a toolchain, and all it needs
# is git and a container runtime. Everything else lives in the image built from
# docker/ci.Dockerfile.
#
#   ./scripts/run-in-container.sh pre-commit run --all-files
#   ./scripts/run-in-container.sh bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
IMAGE="${MUNCHER_CI_IMAGE:-muncher-ci:local}"

cd "$REPO_ROOT"

if ! command -v docker >/dev/null 2>&1; then
	echo "❌ docker not found." >&2
	exit 1
fi

# Built on every invocation: with the layer cache warm this is near-instant, and
# it means a change to the Dockerfile or to front-end/package.json can never
# leave a developer running checks against a stale toolchain.
docker build --quiet -f docker/ci.Dockerfile -t "$IMAGE" . >/dev/null

# node_modules is installed into the image, so it cannot live in the bind mount
# that covers /workspace. A named volume seeded from the image keeps it out of
# the working tree. Keying the volume on the lockfile means a dependency change
# gets a fresh one instead of silently reusing stale packages.
LOCK_HASH="$(git hash-object front-end/yarn.lock | cut -c1-12)"
NODE_MODULES_VOLUME="muncher-front-end-node-modules-${LOCK_HASH}"
VOLUME_LABEL="muncher.role=front-end-node-modules"

# Created explicitly, and labelled, so that the cleanup below can recognise the
# volumes this project owns without pattern-matching on their names.
if ! docker volume inspect "$NODE_MODULES_VOLUME" >/dev/null 2>&1; then
	docker volume create --label "$VOLUME_LABEL" "$NODE_MODULES_VOLUME" >/dev/null
fi

# Every dependency change strands the volume keyed on the previous lockfile, and
# every image rebuild strands the untagged image it replaced. Both are discarded
# here rather than left for a manual prune. Only this project's own resources are
# touched: the label filters out everything else on the machine, and a volume
# still attached to a running container simply refuses to be removed.
#
# Set MUNCHER_KEEP_STALE=1 to keep them — useful when switching branches back and
# forth, where the previous volume is about to be needed again.
if [ "${MUNCHER_KEEP_STALE:-0}" != "1" ]; then
	for volume in $(docker volume ls --quiet --filter "label=$VOLUME_LABEL"); do
		if [ "$volume" != "$NODE_MODULES_VOLUME" ]; then
			docker volume rm "$volume" >/dev/null 2>&1 || true
		fi
	done

	docker image prune --force \
		--filter "label=muncher.image=ci" \
		--filter "dangling=true" >/dev/null 2>&1 || true
fi

exec docker run --rm --init \
	--volume "$REPO_ROOT:/workspace" \
	--volume "$NODE_MODULES_VOLUME:/workspace/front-end/node_modules" \
	--workdir /workspace \
	--env "PRE_COMMIT_COLOR=${PRE_COMMIT_COLOR:-always}" \
	$( [ -t 0 ] && printf '%s' '--interactive --tty' ) \
	"$IMAGE" "$@"
