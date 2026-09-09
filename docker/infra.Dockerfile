# syntax=docker/dockerfile:1

# Image that deploys the infrastructure.
#
# Kept separate from docker/ci.Dockerfile so the image built on every commit does
# not carry the AWS tooling.
#
# Build from the repository root:
#   docker build -f docker/infra.Dockerfile -t muncher-infra:local .

FROM python:3.13-slim

# Lets scripts/run-in-container.sh recognise — and discard — the untagged images
# left behind by its own rebuilds.
LABEL muncher.image=infra

# Only the AWS CLI: validating the templates is a check, and checks live in the
# image built from docker/ci.Dockerfile.
RUN pip install --no-cache-dir awscli==1.46.1

WORKDIR /workspace

CMD ["aws", "--version"]
