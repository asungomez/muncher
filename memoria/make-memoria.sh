#!/bin/bash
mkdir -p generated
pdflatex -output-directory=generated -jobname=memoria src/index.tex