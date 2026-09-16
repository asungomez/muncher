#!/bin/bash
# The only part of the check pipeline that runs on the host, and it only
# delegates. See agents/local-development/containerized-development.md.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"

exec "$REPO_ROOT/scripts/run-in-container.sh" pre-commit run
