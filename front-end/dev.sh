#!/bin/bash
# Starts the front-end development server on http://localhost:5173.
#
# Node.js and Yarn live in the image built from docker/front-end.Dockerfile, not
# on the developer's machine. The server runs inside the container and serves the
# sources bind mounted from the host, so edits reload as usual.
# See agents/local-development/containerized-development.md.
#
# Stop it with Ctrl-C. Set MUNCHER_FRONT_END_PORT to publish on another port.
# Any extra arguments are passed through to `docker compose up`.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

if ! command -v docker >/dev/null 2>&1; then
	echo "❌ docker not found. It is the only tool this project requires on your machine." >&2
	exit 1
fi

# node_modules lives in a named volume seeded from the image, which means a
# dependency change would otherwise keep serving the packages installed when the
# volume was first created. The lockfile hash is recorded outside the working
# tree, and the volume is renewed whenever it moves.
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

exec docker compose up --build "${RENEW_ARGS[@]}" front-end "$@"
