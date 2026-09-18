# One stack per environment. Override with `make infra-deploy ENVIRONMENT=prod`.
ENVIRONMENT ?= dev

.PHONY: infra-lint
infra-lint: ## Validate the CloudFormation templates
	$(RUN) pre-commit run cfn-lint --all-files

.PHONY: infra-deploy
infra-deploy: ## Deploy the stack for ENVIRONMENT (default dev)
	$(RUN) --image infra scripts/infra-deploy.sh $(ENVIRONMENT)

.PHONY: front-end-deploy
front-end-deploy: front-end-build ## Build and upload the front-end to ENVIRONMENT (default dev)
	$(RUN) --image infra scripts/front-end-deploy.sh $(ENVIRONMENT)

.PHONY: api-deploy
api-deploy: api-build ## Build and upload the API to ENVIRONMENT (default dev)
	$(RUN) --image infra scripts/api-deploy.sh $(ENVIRONMENT)
