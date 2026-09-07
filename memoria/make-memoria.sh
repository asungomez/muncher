#!/bin/bash
# Builds the memoria into memoria/generated/.
#
# TeX Live lives in the image built from docker/memoria.Dockerfile, not on the
# developer's machine. When run on the host this script does nothing but
# delegate; the body below executes inside the container.
# See agents/local-development/containerized-development.md.
set -euo pipefail

if [ -z "${MUNCHER_IN_CONTAINER:-}" ]; then
	REPO_ROOT="$(git rev-parse --show-toplevel)"
	exec "$REPO_ROOT/scripts/run-in-container.sh" --image memoria ./make-memoria.sh "$@"
fi

mkdir -p generated
# Two passes so the ToC builds
pdflatex -halt-on-error -interaction=nonstopmode -file-line-error -output-directory=generated -jobname=memoria src/index.tex
pdflatex -halt-on-error -interaction=nonstopmode -file-line-error -output-directory=generated -jobname=memoria src/index.tex
rm -f src/index.aux src/index.fdb_latexmk src/index.fls src/index.log src/index.out src/index.toc src/index.pdf src/index.synctex.gz
