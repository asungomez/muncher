#!/bin/bash
# Runs a command inside one of the project's images, the single place where the
# host touches a toolchain. Usage: [--image <name>] <command>...
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"

# Each name maps to docker/<name>.Dockerfile.
IMAGE_NAME=ci
if [ "${1:-}" = "--image" ]; then
	IMAGE_NAME="$2"
	shift 2
fi

DOCKERFILE="$REPO_ROOT/docker/${IMAGE_NAME}.Dockerfile"
if [ ! -f "$DOCKERFILE" ]; then
	echo "❌ no such image: ${IMAGE_NAME} (expected ${DOCKERFILE})" >&2
	exit 1
fi

IMAGE="muncher-${IMAGE_NAME}:local"

cd "$REPO_ROOT"

if ! command -v docker >/dev/null 2>&1; then
	echo "❌ docker not found. It is the only tool this project requires on your machine." >&2
	exit 1
fi

# Near-instant with a warm cache, and no one can run against a stale toolchain.
docker build --quiet -f "$DOCKERFILE" -t "$IMAGE" . >/dev/null

RUN_ARGS=(
	--rm
	--init
	--volume "$REPO_ROOT:/workspace"
	--env MUNCHER_IN_CONTAINER=1
)

# By prefix, not by name: an explicit list would have to grow with every new
# setting, and forgetting one fails silently rather than loudly.
for name in $(compgen -A variable | grep -E '^(AWS_|MUNCHER_|FRONTEND_LOGIN_)' | sort -u); do
	# Set above; the host's value is meaningless here.
	[ "$name" = "MUNCHER_IN_CONTAINER" ] && continue
	if [ -n "${!name:-}" ]; then
		RUN_ARGS+=(--env "${name}=${!name}")
	fi
done

# A local profile keeps credentials in ~/.aws, invisible without this mount.
if [ -n "${AWS_PROFILE:-}" ] && [ -d "$HOME/.aws" ]; then
	RUN_ARGS+=(--volume "$HOME/.aws:/root/.aws:ro")
fi

# A named volume keeps node_modules out of the bind mount. Keyed on the lockfile
# so a dependency change gets a fresh one rather than stale packages.
NODE_MODULES_VOLUME=""
VOLUME_LABEL="muncher.role=front-end-node-modules"
if [ "$IMAGE_NAME" = "ci" ]; then
	LOCK_HASH="$(git hash-object front-end/yarn.lock | cut -c1-12)"
	NODE_MODULES_VOLUME="muncher-front-end-node-modules-${LOCK_HASH}"

	# Labelled so the cleanup below finds this project's volumes by label.
	if ! docker volume inspect "$NODE_MODULES_VOLUME" >/dev/null 2>&1; then
		docker volume create --label "$VOLUME_LABEL" "$NODE_MODULES_VOLUME" >/dev/null
	fi

	RUN_ARGS+=(--volume "$NODE_MODULES_VOLUME:/workspace/front-end/node_modules")
	RUN_ARGS+=(--env "PRE_COMMIT_COLOR=${PRE_COMMIT_COLOR:-always}")
fi

# Discards the volumes and untagged images that rebuilds strand. The labels keep
# this to the project's own resources. MUNCHER_KEEP_STALE=1 skips it.
if [ "${MUNCHER_KEEP_STALE:-0}" != "1" ]; then
	for volume in $(docker volume ls --quiet --filter "label=$VOLUME_LABEL"); do
		if [ "$volume" != "$NODE_MODULES_VOLUME" ]; then
			docker volume rm "$volume" >/dev/null 2>&1 || true
		fi
	done

	docker image prune --force \
		--filter "label=muncher.image=${IMAGE_NAME}" \
		--filter "dangling=true" >/dev/null 2>&1 || true
fi

if [ -t 0 ]; then
	RUN_ARGS+=(--interactive --tty)
fi

exec docker run "${RUN_ARGS[@]}" "$IMAGE" "$@"
