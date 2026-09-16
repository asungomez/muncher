# syntax=docker/dockerfile:1

# Image that deploys the infrastructure. Separate from ci.Dockerfile so the
# image built on every commit does not carry the AWS tooling.

FROM python:3.13-slim

# Lets scripts/run-in-container.sh discard the untagged images its rebuilds
# leave behind.
LABEL muncher.image=infra

# Only the AWS CLI: validating the templates is a check, and checks run in the
# image built from docker/ci.Dockerfile.
RUN pip install --no-cache-dir awscli==1.46.1

WORKDIR /workspace

CMD ["aws", "--version"]
