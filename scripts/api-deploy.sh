#!/bin/bash
# Uploads the API package to an environment's function. Invoke through
# `make api-deploy ENVIRONMENT=dev`, which builds it first.
set -euo pipefail

if [ -z "${MUNCHER_IN_CONTAINER:-}" ]; then
	echo "❌ this script runs inside the infra container; use 'make api-deploy'" >&2
	exit 1
fi

ENVIRONMENT="${1:?usage: api-deploy.sh <environment>}"
STACK="muncher-${ENVIRONMENT}"
PACKAGE=api/dist/muncher-api.zip

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -f "$PACKAGE" ]; then
	echo "❌ ${PACKAGE} not found. Build the package first." >&2
	exit 1
fi

# The function is read from the stack rather than reconstructed, so this script
# cannot drift from the template that owns it.
output() {
	aws cloudformation describe-stacks \
		--stack-name "$STACK" \
		--query "Stacks[0].Outputs[?OutputKey=='$1'].OutputValue" \
		--output text
}

FUNCTION="$(output ApiFunctionName)"

if [ -z "$FUNCTION" ] || [ "$FUNCTION" = "None" ]; then
	echo "❌ could not read ApiFunctionName from ${STACK}. Is the stack deployed?" >&2
	exit 1
fi

echo "📦 Uploading ${PACKAGE} to ${FUNCTION}..."
aws lambda update-function-code \
	--function-name "$FUNCTION" \
	--zip-file "fileb://${PACKAGE}" \
	--query '[LastUpdateStatus,CodeSize]' \
	--output text

# The upload returns before the code is in service, so without this a failed
# update would be reported as a successful deployment.
aws lambda wait function-updated --function-name "$FUNCTION"

URL="$(output ApiUrl)"
echo "✅ Deployed: ${URL}"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
	echo "### API deployed to \`${ENVIRONMENT}\`: ${URL}" >> "$GITHUB_STEP_SUMMARY"
fi
