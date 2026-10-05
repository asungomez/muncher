#!/bin/bash
# Starts the local stack in the foreground; invoke through `make up`. Extra
# arguments are passed through to `docker compose up`.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

if ! command -v docker >/dev/null 2>&1; then
	echo "❌ docker not found. It is the only tool this project requires on your machine." >&2
	exit 1
fi

# The node_modules volume would otherwise keep serving the packages it was
# seeded with, so it is renewed whenever the lockfile hash moves. Only that
# volume: `down --volumes` would also delete the database.
STAMP=".git/muncher-front-end-lock"
LOCK_HASH="$(git hash-object front-end/yarn.lock)"
if [ ! -f "$STAMP" ] || [ "$(cat "$STAMP")" != "$LOCK_HASH" ]; then
	echo "📦 front-end dependencies changed; renewing node_modules..."
	docker compose down >/dev/null 2>&1 || true
	docker volume rm --force muncher_front-end-node-modules >/dev/null
fi

# Written before starting: the server runs in the foreground until interrupted.
printf '%s' "$LOCK_HASH" > "$STAMP"

exec docker compose up --build "$@"
