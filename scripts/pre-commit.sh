#!/bin/bash
# Pre-commit hook.
#
# This is the only part of the check pipeline that executes on the host, and it
# does nothing but delegate: pre-commit and every tool it drives run inside the
# CI image. See agents/local-development/containerized-development.md.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"

exec "$REPO_ROOT/scripts/run-in-container.sh" pre-commit run
