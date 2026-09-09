#!/bin/bash
# Deploys infra/muncher.yaml as the stack for one environment.
#
# Runs inside the image built from docker/infra.Dockerfile. Invoke it through
# `make infra-deploy ENVIRONMENT=dev`, which takes care of the container.
#
# Credentials come from the environment: locally from your AWS profile, in CI
# from the role assumed through OIDC. Nothing is read from a file in the repo.
set -euo pipefail

if [ -z "${MUNCHER_IN_CONTAINER:-}" ]; then
	echo "❌ this script runs inside the infra container; use 'make infra-deploy'" >&2
	exit 1
fi

ENVIRONMENT="${1:?usage: infra-deploy.sh <environment>}"
STACK="muncher-${ENVIRONMENT}"

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# The template is not validated here: cfn-lint is one of the checks, so it runs
# on every commit and gates the pull request. By the time a change reaches this
# script it has already been validated.
echo "🚀 Deploying ${STACK}..."
# CAPABILITY_NAMED_IAM because the template names the role it creates.
# --no-fail-on-empty-changeset so that redeploying an unchanged template
# succeeds instead of failing the build.
aws cloudformation deploy \
	--template-file infra/muncher.yaml \
	--stack-name "$STACK" \
	--parameter-overrides "Environment=${ENVIRONMENT}" \
	--capabilities CAPABILITY_NAMED_IAM \
	--no-fail-on-empty-changeset \
	--tags "Environment=${ENVIRONMENT}" Project=muncher

echo "✅ Deployed. Stack outputs:"
aws cloudformation describe-stacks \
	--stack-name "$STACK" \
	--query 'Stacks[0].Outputs[].[OutputKey,OutputValue]' \
	--output text
