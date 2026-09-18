# The rendered PDFs are committed, so this is a real file rule rather than a
# phony one: when a diagram's source has not changed, make skips it and the
# renderer's image is never even built.
MEMORIA_DIAGRAMS := $(patsubst %.mmd,%.pdf,$(wildcard memoria/src/diagrams/*.mmd))

memoria/src/diagrams/%.pdf: memoria/src/diagrams/%.mmd
	$(RUN) --image diagrams scripts/memoria-diagrams.sh $<

.PHONY: memoria-diagrams
memoria-diagrams: $(MEMORIA_DIAGRAMS) ## Render the memoria diagrams whose Mermaid source changed

.PHONY: memoria-build
memoria-build: memoria-diagrams ## Build the memoria PDF into memoria/generated/
	$(RUN) --image memoria scripts/memoria-build.sh

# Renders the diagrams once before watching: the loop runs inside the memoria
# container, which carries no renderer, so a diagram edited mid-watch needs this
# target again.
.PHONY: memoria-watch
memoria-watch: memoria-diagrams ## Rebuild the memoria whenever its sources change (Ctrl-C to stop)
	$(RUN) --image memoria scripts/memoria-watch.sh
