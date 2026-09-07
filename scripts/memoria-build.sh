#!/bin/bash
# Builds the memoria into memoria/generated/.
#
# Runs inside the image built from docker/memoria.Dockerfile. Invoke it through
# `make memoria-build`, which takes care of the container.
set -euo pipefail

if [ -z "${MUNCHER_IN_CONTAINER:-}" ]; then
	echo "❌ this script runs inside the memoria container; use 'make memoria-build'" >&2
	exit 1
fi

# Derived from the script's own location: the memoria image carries TeX Live, not
# git, so the repository root cannot be asked for.
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/memoria"

mkdir -p generated
# Two passes so the ToC builds
pdflatex -halt-on-error -interaction=nonstopmode -file-line-error -output-directory=generated -jobname=memoria src/index.tex
pdflatex -halt-on-error -interaction=nonstopmode -file-line-error -output-directory=generated -jobname=memoria src/index.tex
rm -f src/index.aux src/index.fdb_latexmk src/index.fls src/index.log src/index.out src/index.toc src/index.pdf src/index.synctex.gz
