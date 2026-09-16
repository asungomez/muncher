# Entry point for every task. Run `make help` to list the targets.
# See agents/local-development/containerized-development.md.

RUN := ./scripts/run-in-container.sh

.DEFAULT_GOAL := help

include makefiles/local-env.mk
include makefiles/checks.mk
include makefiles/memoria.mk
include makefiles/infra.mk

.PHONY: help
help: ## List the available targets
	@printf 'Usage: make <target>\n\n'
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN { FS = ":.*?## " }; { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 }'
