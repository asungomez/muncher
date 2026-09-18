# Each target selects a hook from .pre-commit-config.yaml by id, so a target
# and the commit-time check cannot drift apart.

.PHONY: checks
checks: ## Run every check over the whole repository
	$(RUN) pre-commit run --all-files

.PHONY: checks-staged
checks-staged: ## Run every check over the staged files only
	$(RUN) pre-commit run

.PHONY: front-end-lint
front-end-lint: ## Analyse the front-end with ESLint
	$(RUN) pre-commit run eslint --all-files

.PHONY: front-end-format
front-end-format: ## Format the front-end with Prettier
	$(RUN) pre-commit run prettier --all-files

.PHONY: front-end-types
front-end-types: ## Regenerate the front-end types from the API's OpenAPI schema
	$(RUN) pre-commit run openapi-types --all-files

.PHONY: api-lint
api-lint: ## Analyse the API with Ruff
	$(RUN) pre-commit run ruff --all-files

.PHONY: api-format
api-format: ## Format the API with Ruff
	$(RUN) pre-commit run ruff-format --all-files

.PHONY: api-types
api-types: ## Type-check the API with ty
	$(RUN) pre-commit run ty --all-files

.PHONY: memoria-lint
memoria-lint: ## Format the memoria sources with latexindent
	$(RUN) pre-commit run latexindent --all-files
