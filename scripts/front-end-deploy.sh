#!/bin/bash
# Uploads the compiled front-end to an environment and invalidates its cache.
# Invoke through `make front-end-deploy ENVIRONMENT=dev`, which builds it first.
set -euo pipefail

if [ -z "${MUNCHER_IN_CONTAINER:-}" ]; then
	echo "❌ this script runs inside the infra container; use 'make front-end-deploy'" >&2
	exit 1
fi

ENVIRONMENT="${1:?usage: front-end-deploy.sh <environment>}"
STACK="muncher-${ENVIRONMENT}"

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -f front-end/dist/index.html ]; then
	echo "❌ front-end/dist/index.html not found. Build the application first." >&2
	exit 1
fi

# The bucket and distribution are read from the stack rather than reconstructed,
# so this script cannot drift from the template that owns them.
output() {
	aws cloudformation describe-stacks \
		--stack-name "$STACK" \
		--query "Stacks[0].Outputs[?OutputKey=='$1'].OutputValue" \
		--output text
}

BUCKET="$(output FrontEndBucketName)"
DISTRIBUTION="$(output FrontEndDistributionId)"

if [ -z "$BUCKET" ] || [ "$BUCKET" = "None" ]; then
	echo "❌ could not read FrontEndBucketName from ${STACK}. Is the stack deployed?" >&2
	exit 1
fi

echo "📦 Uploading to ${BUCKET}..."

# Every other file carries a content hash, so its URL never changes contents.
aws s3 sync front-end/dist "s3://${BUCKET}" \
	--delete \
	--exclude index.html \
	--cache-control "public, max-age=31536000, immutable"

# The one stable URL with changing contents, pointing at the hashed assets.
aws s3 cp front-end/dist/index.html "s3://${BUCKET}/index.html" \
	--cache-control "no-cache, must-revalidate"

# Only index.html: the hashed assets are new paths, and 1,000 paths a month are
# free, so this stays within the free tier.
echo "♻️  Invalidating /index.html on ${DISTRIBUTION}..."
aws cloudfront create-invalidation \
	--distribution-id "$DISTRIBUTION" \
	--paths /index.html / \
	--query 'Invalidation.[Id,Status]' \
	--output text

URL="$(output FrontEndUrl)"
echo "✅ Deployed: ${URL}"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
	echo "### Front-end deployed to \`${ENVIRONMENT}\`: ${URL}" >> "$GITHUB_STEP_SUMMARY"
fi
