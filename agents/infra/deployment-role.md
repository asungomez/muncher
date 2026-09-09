# Deployment role

GitHub Actions deploys by assuming an IAM role in the AWS account, reached
through GitHub's OIDC provider. How to create it, and the exact policies it
carries, are developer instructions and live in
[docs/deployment.md](../../docs/deployment.md).

## The rule

**When a template gains a resource, update the permissions policy in
`docs/deployment.md` in the same change.** That policy is the source of truth
for what the deployment role may do, and a template the role cannot deploy is
not finished.

Work out which actions the resource requires to be **created, updated and
deleted**. Deletion is the one most often missed, and its absence surfaces late:
the stack deploys, then cannot be torn down — which breaks the
delete-and-recreate test that [iac.md](iac.md) relies on.

## Constraints

- **Scope every permission to the `muncher-*` prefix** unless the service does
  not support resource-level ARNs. Where it does not, say so where the policy is
  documented.
- **Never widen the trust policy's `sub` condition.** It is what stops another
  repository from assuming the role.
- **Never propose an access key.** No long-lived AWS credentials exist in this
  project, and none should be introduced.
- **Never add a permission speculatively**, and never reach for `"Action": "*"`
  or a blanket `iam:*`. If you cannot determine the exact actions, list what you
  believe is needed and say it is unverified.
- **Treat an `AccessDenied` during deployment as a missing entry** in that
  policy, not as a reason to loosen it.
