#!/bin/bash
mkdir -p generated
rm -f src/index.aux src/index.fdb_latexmk src/index.fls src/index.log src/index.out src/index.toc src/index.pdf
pdflatex -output-directory=generated -jobname=memoria src/index.tex
rm -f src/index.aux src/index.fdb_latexmk src/index.fls src/index.log src/index.out src/index.toc src/index.pdf src/index.synctex.gz