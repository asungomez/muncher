#!/bin/bash
# Runs a command inside one of the project's images.
#
# This is the single place where the host touches a toolchain, and all it needs
# is git and a container runtime. Everything else lives in the images under
# docker/.
#
#   ./scripts/run-in-container.sh pre-commit run --all-files
#   ./scripts/run-in-container.sh --image memoria ./make-memoria.sh
#   ./scripts/run-in-container.sh bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"

# Which image to run in. "ci" carries the check toolchain, "memoria" carries
# TeX Live. Each maps to docker/<name>.Dockerfile.
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

# Built on every invocation: with the layer cache warm this is near-instant, and
# it means a change to a Dockerfile or to front-end/package.json can never leave
# a developer running against a stale toolchain.
docker build --quiet -f "$DOCKERFILE" -t "$IMAGE" . >/dev/null

RUN_ARGS=(
	--rm
	--init
	--volume "$REPO_ROOT:/workspace"
	--env MUNCHER_IN_CONTAINER=1
)

# Credentials are never stored in the repository or baked into an image: they are
# forwarded from the environment that invoked make — a local profile, or the role
# GitHub Actions assumed through OIDC, plus the login wall credentials. Only
# variables that are actually set are passed on.
for aws_var in \
	AWS_ACCESS_KEY_ID \
	AWS_SECRET_ACCESS_KEY \
	AWS_SESSION_TOKEN \
	AWS_REGION \
	AWS_DEFAULT_REGION \
	AWS_PROFILE \
	FRONTEND_LOGIN_USER \
	FRONTEND_LOGIN_PASSWORD \
	MUNCHER_REQUIRE_LOGIN_WALL; do
	if [ -n "${!aws_var:-}" ]; then
		RUN_ARGS+=(--env "${aws_var}=${!aws_var}")
	fi
done

# A local profile keeps its credentials in ~/.aws, which the container cannot see
# unless it is mounted. Read-only: the container has no reason to write there.
if [ -n "${AWS_PROFILE:-}" ] && [ -d "$HOME/.aws" ]; then
	RUN_ARGS+=(--volume "$HOME/.aws:/root/.aws:ro")
fi

# node_modules is installed into the CI image, so it cannot live in the bind
# mount that covers /workspace. A named volume seeded from the image keeps it out
# of the working tree. Keying the volume on the lockfile means a dependency
# change gets a fresh one instead of silently reusing stale packages.
NODE_MODULES_VOLUME=""
VOLUME_LABEL="muncher.role=front-end-node-modules"
if [ "$IMAGE_NAME" = "ci" ]; then
	LOCK_HASH="$(git hash-object front-end/yarn.lock | cut -c1-12)"
	NODE_MODULES_VOLUME="muncher-front-end-node-modules-${LOCK_HASH}"

	# Created explicitly, and labelled, so that the cleanup below can recognise
	# the volumes this project owns without pattern-matching on their names.
	if ! docker volume inspect "$NODE_MODULES_VOLUME" >/dev/null 2>&1; then
		docker volume create --label "$VOLUME_LABEL" "$NODE_MODULES_VOLUME" >/dev/null
	fi

	RUN_ARGS+=(--volume "$NODE_MODULES_VOLUME:/workspace/front-end/node_modules")
	RUN_ARGS+=(--env "PRE_COMMIT_COLOR=${PRE_COMMIT_COLOR:-always}")
fi

# Every dependency change strands the volume keyed on the previous lockfile, and
# every image rebuild strands the untagged image it replaced. Both are discarded
# here rather than left for a manual prune. Only this project's own resources are
# touched: the labels filter out everything else on the machine, and a volume
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
		--filter "label=muncher.image=${IMAGE_NAME}" \
		--filter "dangling=true" >/dev/null 2>&1 || true
fi

if [ -t 0 ]; then
	RUN_ARGS+=(--interactive --tty)
fi

exec docker run "${RUN_ARGS[@]}" "$IMAGE" "$@"
