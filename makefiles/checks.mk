# Checks.
#
# Every target here runs pre-commit, which is the single definition of what the
# checks are. The individual targets select one of its hooks by id, so a target
# and the corresponding commit-time check can never drift apart — and neither can
# either of them drift from continuous integration, which runs the same command.

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

.PHONY: memoria-lint
memoria-lint: ## Format the memoria sources with latexindent
	$(RUN) pre-commit run latexindent --all-files
