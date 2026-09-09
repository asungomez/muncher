# Entry point for every task in this repository.
#
# Targets are grouped by subsystem in makefiles/, and named after the subsystem
# they act on: front-end-*, memoria-*. Everything they run happens inside a
# container, so the only tools required on your machine are git and Docker.
# See agents/local-development/containerized-development.md.
#
# Run `make` or `make help` to list the available targets.

# Runs a command inside one of the project's images. Defined here so that every
# included fragment can use it.
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
