#!/bin/bash
# Regenerates the front-end's view of the API's types; invoke through
# `make front-end-types`. FastAPI derives the schema from the endpoint
# annotations, so nothing has to be running for this to be accurate.
set -euo pipefail

if [ -z "${MUNCHER_IN_CONTAINER:-}" ]; then
	echo "❌ this script runs inside the check container; use 'make front-end-types'" >&2
	exit 1
fi

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SCHEMA_FILE="$(mktemp --suffix=.json)"
trap 'rm -f "$SCHEMA_FILE"' EXIT

# The schema is an intermediate artifact, not a source: only the TypeScript it
# produces is committed, so the two cannot describe different APIs.
# -B because api/src is the bind mounted working tree: no .pyc may land in it.
PYTHONPATH=api/src python -B -c '
import json

from muncher_api.main import app

print(json.dumps(app.openapi(), indent=2, sort_keys=True))
' > "$SCHEMA_FILE"

cd front-end

TYPES_FILE=src/services/api/schema.d.ts
yarn openapi-typescript "$SCHEMA_FILE" --output "$TYPES_FILE"

# openapi-typescript does not format its output, and the prettier hook would
# otherwise reformat the file this one just wrote, each undoing the other.
yarn prettier --write --log-level=warn "$TYPES_FILE"
