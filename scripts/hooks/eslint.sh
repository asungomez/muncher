#!/bin/bash
# ESLint hook. pre-commit passes paths from the repository root, while ESLint
# must run from front-end/, where its config and dependencies live.
set -euo pipefail

cd front-end
printf '%s\n' "$@" | sed 's|^front-end/||' | xargs yarn eslint --fix --max-warnings=0
