#!/bin/bash
# Builds the archive Lambda runs: the locked dependencies, resolved for the
# function's platform, with the API's sources at the root of it.
# Invoke through `make api-build`.
set -euo pipefail

if [ -z "${MUNCHER_IN_CONTAINER:-}" ]; then
	echo "❌ this script runs inside the api container; use 'make api-build'" >&2
	exit 1
fi

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/api"

STAGING=build
PACKAGE=dist/muncher-api.zip

rm -rf "$STAGING" "$PACKAGE"
mkdir -p "$STAGING" dist

# Exported from the lockfile rather than resolved again, so the versions that
# run in the cloud are the ones that were committed. The function's
# OpenTelemetry layer ships the API its SDK was built against; a copy here
# would shadow it, and the SDK fails to load against a newer one.
uv export --frozen --no-dev --no-emit-project --no-emit-package opentelemetry-api \
	--quiet -o "$STAGING/requirements.txt"

# The function's platform, not this container's: pydantic-core and the rest ship
# compiled wheels, and the ones built for this image would not load on arm64.
# --no-deps because the export is already the complete set; resolving it again
# would bring back what it leaves out.
echo "📦 Installing the locked dependencies for arm64..."
uv pip install \
	--quiet \
	--no-deps \
	--target "$STAGING" \
	--python-platform aarch64-manylinux2014 \
	--python-version 3.13 \
	--requirements "$STAGING/requirements.txt"

rm "$STAGING/requirements.txt"

# Lambda resolves the handler from the root of the archive, which is why the
# sources sit next to the dependencies instead of under src/.
cp -r src/muncher_api "$STAGING/"
find "$STAGING" -name __pycache__ -type d -prune -exec rm -rf {} +

# python -m zipfile, rather than a zip binary the image would otherwise carry
# for this one step.
(cd "$STAGING" && python -m zipfile -c "../$PACKAGE" ./*)

echo "✅ Built api/${PACKAGE} ($(du -h "$PACKAGE" | cut -f1 | tr -d ' '))"
