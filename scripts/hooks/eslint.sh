#!/bin/bash
# ESLint hook. Runs inside the CI image; never on the host.
#
# pre-commit passes paths relative to the repository root, while ESLint has to
# run from front-end/ where its config and dependencies live.
set -euo pipefail

cd front-end
printf '%s\n' "$@" | sed 's|^front-end/||' | xargs yarn eslint --fix --max-warnings=0
