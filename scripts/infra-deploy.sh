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

stack_status() {
	aws cloudformation describe-stacks \
		--stack-name "$STACK" \
		--query 'Stacks[0].StackStatus' \
		--output text 2>/dev/null || echo "DOES_NOT_EXIST"
}

# Prints why the deployment failed, so the reason is in this output rather than
# only in the console. CloudFormation reports the cause on the individual
# resource, not on the stack, and lists events newest first — the oldest failure
# is the real one, everything after it is fallout from the rollback.
report_failure() {
	echo ""
	echo "::group::CloudFormation failures for ${STACK}"
	aws cloudformation describe-stack-events \
		--stack-name "$STACK" \
		--query "reverse(StackEvents[?contains(ResourceStatus, 'FAILED')].[Timestamp,LogicalResourceId,ResourceType,ResourceStatusReason])" \
		--output table 2>/dev/null || echo "(no events could be read)"
	echo "::endgroup::"

	# The first failure, repeated outside the collapsed group so it is visible
	# without expanding anything, and added to the run summary.
	local reason
	reason="$(aws cloudformation describe-stack-events \
		--stack-name "$STACK" \
		--query "reverse(StackEvents[?ResourceStatusReason!=null && contains(ResourceStatus, 'FAILED')])[0].[LogicalResourceId,ResourceStatusReason]" \
		--output text 2>/dev/null || true)"

	if [ -n "$reason" ]; then
		echo ""
		echo "❌ First failure: ${reason}"
		if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
			{
				echo "### Deployment of \`${STACK}\` failed"
				echo ""
				echo '```'
				echo "${reason}"
				echo '```'
			} >> "$GITHUB_STEP_SUMMARY"
		fi
	fi
}

STATUS="$(stack_status)"

# A stack whose creation failed holds no resources and cannot be updated, so it
# has to be removed before another attempt. Deleting it is safe precisely
# because nothing was ever provisioned.
if [ "$STATUS" = "ROLLBACK_COMPLETE" ] || [ "$STATUS" = "REVIEW_IN_PROGRESS" ]; then
	echo "🧹 ${STACK} is in ${STATUS} from a failed creation; deleting it first..."
	aws cloudformation delete-stack --stack-name "$STACK"
	aws cloudformation wait stack-delete-complete --stack-name "$STACK"
fi

# The login wall is enabled by supplying both halves of the credential. They
# arrive as environment variables — from the dev environment's secrets in CI —
# and are simply absent for environments that should be public.
PARAMETERS=("Environment=${ENVIRONMENT}")
if [ -n "${FRONTEND_LOGIN_USER:-}" ] && [ -n "${FRONTEND_LOGIN_PASSWORD:-}" ]; then
	PARAMETERS+=(
		"FrontEndLoginUser=${FRONTEND_LOGIN_USER}"
		"FrontEndLoginPassword=${FRONTEND_LOGIN_PASSWORD}"
	)
	echo "🔒 Login wall enabled for ${ENVIRONMENT}"
elif [ -n "${FRONTEND_LOGIN_USER:-}" ] || [ -n "${FRONTEND_LOGIN_PASSWORD:-}" ]; then
	# Half a credential is a misconfiguration, not a request for a public site:
	# saying so is better than silently deploying without a wall.
	echo "❌ FRONTEND_LOGIN_USER and FRONTEND_LOGIN_PASSWORD must be set together" >&2
	exit 1
elif [ -n "${MUNCHER_REQUIRE_LOGIN_WALL:-}" ]; then
	# This environment is not allowed to be publicly reachable, so missing
	# credentials are a failure rather than a decision to serve it openly.
	# Reaching here means the secrets are not visible to the deployment: check
	# that they are defined on the environment being deployed.
	echo "❌ ${ENVIRONMENT} requires the login wall, but FRONTEND_LOGIN_USER and" >&2
	echo "   FRONTEND_LOGIN_PASSWORD are empty. Define them as secrets of the" >&2
	echo "   ${ENVIRONMENT} environment; see docs/deployment.md." >&2
	exit 1
else
	echo "🔓 No login wall for ${ENVIRONMENT}: no credentials supplied"
fi

echo "🚀 Deploying ${STACK}..."
# CAPABILITY_NAMED_IAM because the template names the role it creates.
# --no-fail-on-empty-changeset so that redeploying an unchanged template
# succeeds instead of failing the build.
if ! aws cloudformation deploy \
	--template-file infra/muncher.yaml \
	--stack-name "$STACK" \
	--parameter-overrides "${PARAMETERS[@]}" \
	--capabilities CAPABILITY_NAMED_IAM \
	--no-fail-on-empty-changeset \
	--tags "Environment=${ENVIRONMENT}" Project=muncher; then
	report_failure
	exit 1
fi

echo "✅ Deployed. Stack outputs:"
aws cloudformation describe-stacks \
	--stack-name "$STACK" \
	--query 'Stacks[0].Outputs[].[OutputKey,OutputValue]' \
	--output text
