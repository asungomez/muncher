.PHONY: memoria-build
memoria-build: ## Build the memoria PDF into memoria/generated/
	$(RUN) --image memoria scripts/memoria-build.sh

.PHONY: memoria-watch
memoria-watch: ## Rebuild the memoria whenever its sources change (Ctrl-C to stop)
	$(RUN) --image memoria scripts/memoria-watch.sh
