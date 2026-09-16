# Local environment: the running application.
#
# Services are declared in compose.yaml and share a network, so they can reach
# each other by name. The front-end and the API are the ones for now; the
# database joins the same stack as it is built.

.PHONY: up
up: ## Start the local stack in the foreground (Ctrl-C to stop)
	./scripts/local-env-up.sh

.PHONY: front-end-up
front-end-up: ## Start only the front-end service
	./scripts/local-env-up.sh front-end

.PHONY: front-end-build
front-end-build: ## Build the front-end deployable artifacts
	$(RUN) bash -c 'cd front-end && yarn build'

.PHONY: api-up
api-up: ## Start only the API service
	./scripts/local-env-up.sh api

.PHONY: api-shell
api-shell: ## Open a shell in the API container
	$(RUN) --image api bash

# Pinned by the caller, as in `make api-install-dep DEP=httpx==0.28.1`. A bare
# name installs the newest version and pins that. The package cannot be given
# as a bare word — make reads any command-line argument containing '=' as a
# variable assignment, and a version specifier is full of them.
.PHONY: api-install-dep
api-install-dep: ## Add a dependency to the API (DEP=package==version)
	@test -n "$(DEP)" || { echo "❌ usage: make api-install-dep DEP=package==version" >&2; exit 1; }
	./scripts/api-deps.sh add '$(DEP)' --no-sync

.PHONY: api-remove-dep
api-remove-dep: ## Remove a dependency from the API (DEP=package)
	@test -n "$(DEP)" || { echo "❌ usage: make api-remove-dep DEP=package" >&2; exit 1; }
	./scripts/api-deps.sh remove '$(DEP)' --no-sync

.PHONY: api-lock
api-lock: ## Re-resolve api/uv.lock from api/pyproject.toml
	./scripts/api-deps.sh lock

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
