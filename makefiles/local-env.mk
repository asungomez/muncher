# The services themselves are declared in compose.yaml.

.PHONY: up
up: ## Start the local stack in the foreground (Ctrl-C to stop)
	./scripts/local-env-up.sh

.PHONY: front-end-up
front-end-up: ## Start only the front-end service
	./scripts/local-env-up.sh front-end

.PHONY: front-end-build
front-end-build: ## Build the front-end deployable artifacts
	$(RUN) bash -c 'cd front-end && yarn build'

# DEP is a variable, not a bare argument: make reads any argument containing
# '=' as an assignment. DEV=1 adds it as a development dependency.
.PHONY: front-end-install-dep
front-end-install-dep: ## Add a dependency to the front-end (DEP=package@version, DEV=1)
	@test -n "$(DEP)" || { echo "❌ usage: make front-end-install-dep DEP=package@version [DEV=1]" >&2; exit 1; }
	$(RUN) bash -c "cd front-end && yarn add $(if $(DEV),--dev) '$(DEP)'"

.PHONY: front-end-remove-dep
front-end-remove-dep: ## Remove a dependency from the front-end (DEP=package)
	@test -n "$(DEP)" || { echo "❌ usage: make front-end-remove-dep DEP=package" >&2; exit 1; }
	$(RUN) bash -c "cd front-end && yarn remove '$(DEP)'"

.PHONY: front-end-lock
front-end-lock: ## Re-resolve front-end/yarn.lock from front-end/package.json
	./scripts/front-end-lock.sh

.PHONY: api-up
api-up: ## Start only the API service
	./scripts/local-env-up.sh api

.PHONY: api-shell
api-shell: ## Open a shell in the API container
	$(RUN) --image api bash

# DEP is a variable, not a bare argument: make reads any argument containing
# '=' as an assignment. GROUP picks a dependency group over a runtime one.
.PHONY: api-install-dep
api-install-dep: ## Add a dependency to the API (DEP=package==version, GROUP=group)
	@test -n "$(DEP)" || { echo "❌ usage: make api-install-dep DEP=package==version [GROUP=group]" >&2; exit 1; }
	./scripts/api-deps.sh add $(if $(GROUP),--group '$(GROUP)') '$(DEP)' --no-sync

.PHONY: api-remove-dep
api-remove-dep: ## Remove a dependency from the API (DEP=package, GROUP=group)
	@test -n "$(DEP)" || { echo "❌ usage: make api-remove-dep DEP=package [GROUP=group]" >&2; exit 1; }
	./scripts/api-deps.sh remove $(if $(GROUP),--group '$(GROUP)') '$(DEP)' --no-sync

.PHONY: api-lock
api-lock: ## Re-resolve api/uv.lock from api/pyproject.toml
	./scripts/api-deps.sh lock

# In the api image, which carries uv; the upload runs in the infra one.
.PHONY: api-build
api-build: ## Build the API deployment package for Lambda
	$(RUN) --image api /workspace/scripts/api-build.sh

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
