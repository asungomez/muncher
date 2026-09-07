# Local environment: the running application.
#
# Services are declared in compose.yaml and share a network, so they can reach
# each other by name. The front-end is the only one for now; the API and the
# database join the same stack as they are built.

.PHONY: up
up: ## Start the local stack in the foreground (Ctrl-C to stop)
	./scripts/front-end-dev.sh

.PHONY: front-end-up
front-end-up: ## Start only the front-end service
	./scripts/front-end-dev.sh front-end

.PHONY: front-end-build
front-end-build: ## Build the front-end deployable artifacts
	$(RUN) bash -c 'cd front-end && yarn build'

.PHONY: down
down: ## Stop the local stack and remove its containers
	docker compose down

.PHONY: logs
logs: ## Follow the logs of the running stack
	docker compose logs --follow

.PHONY: shell
shell: ## Open a shell in the check container
	$(RUN) bash

.PHONY: setup
setup: ## Install the git hooks (run once after cloning)
	./scripts/setup-hooks.sh
