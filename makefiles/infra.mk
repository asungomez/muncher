# Infrastructure.
#
# Templates live in infra/ and are deployed with the image built from
# docker/infra.Dockerfile, which carries the AWS CLI. One stack per environment:
# the environment name is the only parameter the template takes.

# Which environment to act on. Overridden on the command line:
#   make infra-deploy ENVIRONMENT=prod
ENVIRONMENT ?= dev

.PHONY: infra-lint
infra-lint: ## Validate the CloudFormation templates
	$(RUN) pre-commit run cfn-lint --all-files

.PHONY: infra-deploy
infra-deploy: ## Deploy the stack for ENVIRONMENT (default dev)
	$(RUN) --image infra scripts/infra-deploy.sh $(ENVIRONMENT)
