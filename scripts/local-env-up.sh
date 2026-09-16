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
# seeded with, so it is renewed whenever the lockfile hash moves.
STAMP=".git/muncher-front-end-lock"
LOCK_HASH="$(git hash-object front-end/yarn.lock)"
RENEW_ARGS=()
if [ ! -f "$STAMP" ] || [ "$(cat "$STAMP")" != "$LOCK_HASH" ]; then
	echo "📦 front-end dependencies changed; renewing node_modules..."
	RENEW_ARGS+=(--renew-anon-volumes)
	docker compose down --volumes >/dev/null 2>&1 || true
fi

# Written before starting: the server runs in the foreground until interrupted.
printf '%s' "$LOCK_HASH" > "$STAMP"

# Expanded defensively: under `set -u`, bash 3.2 (macOS's default) treats an
# empty array expansion as an unbound variable.
exec docker compose up --build ${RENEW_ARGS[@]+"${RENEW_ARGS[@]}"} "$@"
