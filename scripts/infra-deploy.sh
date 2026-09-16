#!/bin/bash
# Deploys infra/muncher.yaml as the stack for one environment. Invoke through
# `make infra-deploy ENVIRONMENT=dev`. Credentials come from the environment.
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

# CloudFormation reports the cause on the resource, not the stack, newest first.
# The oldest failure is the real one; the rest is rollback fallout.
report_failure() {
	echo ""
	echo "::group::CloudFormation failures for ${STACK}"
	aws cloudformation describe-stack-events \
		--stack-name "$STACK" \
		--query "reverse(StackEvents[?contains(ResourceStatus, 'FAILED')].[Timestamp,LogicalResourceId,ResourceType,ResourceStatusReason])" \
		--output table 2>/dev/null || echo "(no events could be read)"
	echo "::endgroup::"

	# Repeated outside the collapsed group, so it is visible unexpanded.
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

# A stack whose creation failed holds no resources and cannot be updated, so
# deleting it before retrying is both necessary and safe.
if [ "$STATUS" = "ROLLBACK_COMPLETE" ] || [ "$STATUS" = "REVIEW_IN_PROGRESS" ]; then
	echo "🧹 ${STACK} is in ${STATUS} from a failed creation; deleting it first..."
	aws cloudformation delete-stack --stack-name "$STACK"
	aws cloudformation wait stack-delete-complete --stack-name "$STACK"
fi

# A CloudFront certificate must live in us-east-1, which CloudFormation cannot
# reach from another region, so it gets its own stack and passes its ARN over.
CERTIFICATE_ARN=""
if [ -n "${MUNCHER_DOMAIN_NAME:-}" ]; then
	# The zone belongs to the domain registration and outlives any stack, so it
	# is looked up, not created. stderr is kept: it is the only failure output.
	if ! zone_lookup="$(
		aws route53 list-hosted-zones-by-name \
			--dns-name "${MUNCHER_DOMAIN_NAME}." \
			--max-items 1 \
			--query 'HostedZones[0].[Id,Name]' \
			--output text 2>&1
	)"; then
		echo "❌ could not look up the hosted zone for ${MUNCHER_DOMAIN_NAME}:" >&2
		echo "   ${zone_lookup}" >&2
		exit 1
	fi

	HOSTED_ZONE_ID="$(
		printf '%s\n' "$zone_lookup" |
			awk -v want="${MUNCHER_DOMAIN_NAME}." '$2 == want { sub(".*/", "", $1); print $1 }'
	)"

	if [ -z "$HOSTED_ZONE_ID" ]; then
		echo "❌ no Route 53 hosted zone found for ${MUNCHER_DOMAIN_NAME}." >&2
		echo "   Route 53 returned: ${zone_lookup}" >&2
		echo "   Register the domain with Route 53, or delegate it to a zone in" >&2
		echo "   this account; see docs/deployment.md." >&2
		exit 1
	fi

	echo "🔐 Issuing the certificate for ${MUNCHER_DOMAIN_NAME} in us-east-1..."
	echo "   (validation is automatic but can take a few minutes)"
	aws cloudformation deploy \
		--region us-east-1 \
		--template-file infra/certificate.yaml \
		--stack-name "${STACK}-certificate" \
		--parameter-overrides \
		"Environment=${ENVIRONMENT}" \
		"DomainName=${MUNCHER_DOMAIN_NAME}" \
		"UseEnvironmentSubdomain=${MUNCHER_USE_ENVIRONMENT_SUBDOMAIN:-true}" \
		"HostedZoneId=${HOSTED_ZONE_ID}" \
		--no-fail-on-empty-changeset \
		--tags "Environment=${ENVIRONMENT}" Project=muncher

	CERTIFICATE_ARN="$(
		aws cloudformation describe-stacks \
			--region us-east-1 \
			--stack-name "${STACK}-certificate" \
			--query "Stacks[0].Outputs[?OutputKey=='CertificateArn'].OutputValue" \
			--output text
	)"
fi

PARAMETERS=("Environment=${ENVIRONMENT}")
if [ -n "${MUNCHER_DOMAIN_NAME:-}" ]; then
	PARAMETERS+=(
		"DomainName=${MUNCHER_DOMAIN_NAME}"
		"UseEnvironmentSubdomain=${MUNCHER_USE_ENVIRONMENT_SUBDOMAIN:-true}"
		"CertificateArn=${CERTIFICATE_ARN}"
	)
fi
if [ -n "${FRONTEND_LOGIN_USER:-}" ] && [ -n "${FRONTEND_LOGIN_PASSWORD:-}" ]; then
	PARAMETERS+=(
		"FrontEndLoginUser=${FRONTEND_LOGIN_USER}"
		"FrontEndLoginPassword=${FRONTEND_LOGIN_PASSWORD}"
	)
	echo "🔒 Login wall enabled for ${ENVIRONMENT}"
elif [ -n "${FRONTEND_LOGIN_USER:-}" ] || [ -n "${FRONTEND_LOGIN_PASSWORD:-}" ]; then
	# Half a credential is a misconfiguration, not a request for a public site.
	echo "❌ FRONTEND_LOGIN_USER and FRONTEND_LOGIN_PASSWORD must be set together" >&2
	exit 1
elif [ -n "${MUNCHER_REQUIRE_LOGIN_WALL:-}" ]; then
	# This environment may not be public, so missing credentials are a failure
	# rather than a decision to serve it openly.
	echo "❌ ${ENVIRONMENT} requires the login wall, but FRONTEND_LOGIN_USER and" >&2
	echo "   FRONTEND_LOGIN_PASSWORD are empty. In CI they come from the secrets of" >&2
	echo "   the ${ENVIRONMENT} environment; see docs/deployment.md." >&2
	exit 1
else
	echo "🔓 No login wall for ${ENVIRONMENT}: no credentials supplied"
fi

echo "🚀 Deploying ${STACK}..."
# CAPABILITY_NAMED_IAM because the template names the role it creates, and an
# empty changeset must not fail a redeploy of an unchanged template.
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
