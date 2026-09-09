# Infrastructure as code

## The principle

**All infrastructure is defined as code, in AWS CloudFormation templates under
`infra/`.** Nothing is created by hand.

A resource that exists in an AWS account but not in a template does not count as
infrastructure — it counts as drift, and it is a defect to report. The same goes
for a change made in the console to a resource a template owns: the template is
the only description of what should exist, and reality is expected to match it.

The project is migrating from Render to AWS. `render.yaml` is what the previous
setup looked like; it is not a source of truth for anything new, and the goal is
its removal.

## One template, many environments

**A single template defines every environment.** Development and production are
not two templates, two directories or two branches of a conditional — they are
two *stacks* created from the same file with different parameter values.

Deploying a new environment should therefore be nothing more than creating a new
stack from the template and supplying its parameters. If it requires anything
else — an extra manual step, a second template, an edit to the file — the
template is wrong.

This is what makes the environments comparable. When development and production
are described by the same code, a change reaches production having already been
exercised in development, and a discrepancy between them is a parameter value
rather than an unknown.

## Keep the parameter surface minimal

**The fewer parameters a template has, the less the environments can drift.**
Every parameter is a value that can differ between stacks, and therefore a way
for development to stop predicting production. The ideal template takes the
environment name and nothing else.

So, before adding a parameter, try to remove the need for it:

- **Derive rather than parameterise.** A name, a tag or a comment that varies by
  environment is built from the environment name with `Fn::Sub`, not passed in.
  Account id, region and partition come from pseudo parameters
  (`AWS::AccountId`, `AWS::Region`, `AWS::Partition`), never from a parameter.
- **Ask whether it really has to differ.** A setting that could be identical in
  both environments should be identical, and then it is a constant in the
  template rather than an input.
- **A parameter is justified when a value cannot be derived and genuinely must
  differ** — a capacity that would be wasteful in development, a retention
  period, an externally supplied identifier. Then it takes a default that suits
  development, so production is the stack that overrides it.

A parameter added "for flexibility", with both stacks passing the same value, is
drift waiting to happen. Remove it.

## One run, from nothing

**Creating the stack once, in an empty account and region, must produce a
working environment.** No second pass, no manual step in between, no resource
that has to exist beforehand.

This rules out a set of patterns that are easy to fall into:

- **Deploy-twice templates.** Anything that only works if you create the stack,
  then edit or redeploy it to wire something up.
- **Commenting out for the first pass.** If a resource has to be disabled on
  first deploy and enabled afterwards, the dependency is modelled wrong.
- **Manual prerequisites.** A bucket, secret, parameter, role or table that
  someone is expected to create by hand first.
- **Hardcoded identifiers.** An ARN, bucket name, security group or subnet id
  written as a literal because it exists in the account today. Reference
  resources with `Ref` and `Fn::GetAtt`, and take genuinely external values as
  parameters.

Order the resources so that CloudFormation can work it out: express real
dependencies through `Ref` and `Fn::GetAtt`, and use `DependsOn` only where a
dependency exists that those do not express. Where two resources appear to need
each other, one of them almost always needs splitting.

Some things genuinely cannot live inside the stack — a registered domain, or a
certificate that must exist in another region. Those are **inputs**, taken as
parameters and documented as prerequisites with how to obtain them. They are the
exception, and each one has to be justified; they are not a licence to push
setup steps out of the template.

Two consequences worth keeping in mind:

- **A failed creation must roll back to nothing.** Retention and deletion
  policies that leave resources behind turn a failed first attempt into a second
  attempt that cannot succeed, because the names are taken.
- **The test is deletion and recreation.** A development stack that can be
  deleted and created again from the template is the only proof this property
  holds. It is also free, per [design.md](design.md), so there is no reason not
  to verify it that way.

## What follows from that

- **Nothing that differs between environments is hardcoded.** Instance sizes,
  capacities, retention periods and the like are either derived from the
  environment name or, where that is impossible, taken as a parameter — subject
  to the section above.
- **Name resources from the environment parameter**, never with a fixed string.
  Two stacks from the same template must be able to coexist in one account and
  one region without colliding.
- **Parameters carry sensible defaults where a sensible default exists**, so
  that creating a development stack requires supplying as little as possible,
  and production is the stack that overrides them.
- **Defaults are the cheap option.** A parameter left unset must never
  provision production-sized resources.
- **No secrets in a template or in its parameters.** Reference them from a
  service intended for the purpose; never a literal, never a committed value.
- **Prefer parameters to conditions.** A condition per environment reintroduces
  the two-templates problem in a single file. Use one where AWS genuinely
  requires a resource to be present or absent, not to express "production is
  different".
- **The template is deployable from a clean account in a single run**, as above.

## Consequences for agents

- To change infrastructure, edit a template under `infra/`. Never propose a
  console click or a one-off CLI command as the way to make a change.
- When adding a resource, decide which of its properties belong in parameters
  before writing it, and say why for anything you hardcode.
- If a change would work in one environment but not the other, stop: that is a
  sign it belongs in a parameter.
- When you find a resource that no template describes, report it rather than
  adopting it silently.
- Never resolve a deployment problem by adding a manual step. If a template
  cannot create something in one pass, fix the modelling or report the
  limitation.
- Keep `render.yaml` out of new work. If a task would extend it, ask whether the
  intent was the AWS equivalent.
