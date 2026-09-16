#!/bin/bash
# latexindent hook. The image carries its Perl dependencies, so a failure here
# is a real one and never a missing tool.
set -euo pipefail

for file in "$@"; do
	latexindent -s -w "$file"
	# latexindent leaves a numbered backup next to the file it formatted.
	rm -f "${file}.bak" "${file%.tex}.bak"*
done
